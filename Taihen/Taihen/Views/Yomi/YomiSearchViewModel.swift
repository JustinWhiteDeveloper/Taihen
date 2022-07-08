import Foundation
import SwiftUI
import TaihenDictionarySupport
import AVFoundation
import LaughingOctoAdventure

private enum Strings {
    static let loadingText = NSLocalizedString("Loading", comment: "")
    static let noResultsText = NSLocalizedString("No results", comment: "")
}

private enum Sizings {
    static let maximumAudioSize = 52288
    static let reviewAsKnownSize = 10000
}

class YomiSearchViewModel: ObservableObject {
    @Published var hasBooted = false
    @Published var lastResultCount = 0
    @Published var isLoading = true
    @Published var finishedLoadingDelay = true
    @Published var lookupTime: Double = 0
    @Published var searchModel: TaihenSearchViewModel?

    @Published var loadingText = Strings.loadingText
    @Published var player: AVPlayer?
    @State var lastSearch = "*"
    @Published var lastSearchString = "*"

    @Published var didSearch: Bool = false
    @Published var hasAnkiCard: Bool = false
    @Published var isReviewed: Bool = false
    @Published var cardText: String = ""
    @Published var ankiExpressionText: String = ""
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(onRecieveNotification(notification:)),
                                               name: Notification.Name.onSelectionChange,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func onLoad() {
        SharedManagedDataController.tagManagementInstance.reloadTags()
        SharedManagedDataController.dictionaryInstance.reloadDictionaries()
    }
    
    func autoplayAudioIfAvailable() {
        guard let url = self.searchModel?.audioUrl,
              FeatureManager.instance.autoplayAudio else {
            return
        }
             
        self.playAudioUrl(url)
    }
    
    func playAudioUrl(_ url: URL?) {
        
        guard let url = url else {
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { result, response, error in
            
            guard let audioData = result else {
                return
            }
            
            if audioData.count >= Sizings.maximumAudioSize {
                return
            }
            
            let tmpFileUrl = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent("audio" + NSUUID().uuidString)
                                .appendingPathExtension("mp3")
            
            let wasFileWritten = (try? audioData.write(to: tmpFileUrl, options: [.atomic])) != nil

            if wasFileWritten {
                
                DispatchQueue.main.async {
                    self.player = AVPlayer(url: tmpFileUrl)
                    self.player?.volume = 1.0
                    self.player?.play()
                }
            }
        }).resume()
        
    }
    
    func onPasteChange() {
        guard FeatureManager.instance.clipboardReadingEnabled,
           let latestItem = NSPasteboard.general.clipboardContent()?.trimingTrailingSpaces(),
                CopyboardEnabler.enabled,
              latestItem.count < 100 else {
            
            return
        }
            
        //Prevent accidently copying english text
        if latestItem.containsValidJapaneseCharacters == false || latestItem.contains("expression") {
            return
        }
    
        onSearch(value: latestItem)
    }
    
    func onSearch(value: String) {
                
        if self.lastSearch == value {
            return
        }

        self.lastSearch = value

        self.lastSearchString = value
        self.hasBooted = true
        self.isLoading = true
        
        // Reset and add timer
        self.finishedLoadingDelay = false
        self.lookupTime = 0
        
        self.didSearch = false
        self.hasAnkiCard = false
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.finishedLoadingDelay = true
        }
        
        SharedManagedDataController
            .dictionaryInstance
            .searchValue(value: value) { finished, timeTaken, results, resultCount in
            
            DispatchQueue.main.async {
                self.lookupTime = timeTaken
                self.isLoading = false
                self.searchModel = results.searchModel
                self.lastResultCount = resultCount
                self.finishedLoadingDelay = false
                
                self.onSearchFinished(results: results)
            }
        }
    }
    
    func onParentValueChange(newValue: String) {
        onSearch(value: newValue)
    }
    
    @objc func onRecieveNotification(notification: Notification) {
        if let outputText = notification.object as? String,
            outputText != lastSearch {
            onSearch(value: outputText)
        }
    }

    func onSearchFinished(results: TaihenSearchResult) {
        
        print("didSearch")
        
        self.didSearch = false
        self.hasAnkiCard = false

        guard let searchModel = results.searchModel else {
            return
        }
        
        cardText = searchModel.furiganaTerm
        
        let ankiExpression = searchModel.ankiExpression
        ankiExpressionText = ankiExpression

        let searcher = ConcreteAnkiInterface()
        searcher.findCards(expression: ankiExpression) { result in
            
            guard let result = result else {
                return
            }
            
            if let error = result.error {
                print(error)
                return
            }
            
            let innerResult = result.result
            print(innerResult)

            if innerResult.count > 0 {
                
                searcher.getCardInfo(values: innerResult) { result in
                    
                    guard let result = result else {
                        return
                    }
                    
                    if let error = result.error {
                        print(error)
                        return
                    }
                
                    DispatchQueue.main.async {

                        if let dueDate = result.result
                            .map({ $0.due })
                            .sorted()
                            .first {
                            
                            self.hasAnkiCard = true
                            self.didSearch = true
                            self.isReviewed = dueDate < Sizings.reviewAsKnownSize
                        }
                    }
                }
            } else {
                self.didSearch = true
            }
        }
        
        autoplayAudioIfAvailable()

    }
    
    func onCopyButtonPressed() {
        
        guard let searchModel = self.searchModel else {
            return
        }
        
        let copyText = searchModel.clipboardDescription
        
        CopyboardEnabler.enabled = false
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString( copyText, forType: .string)
                        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            CopyboardEnabler.enabled = true
        }
    }
    
    func onAnkiPromptButtonPressed() {
        
        guard let searchModel = self.searchModel else {
            return
        }
        
        let searcher = ConcreteAnkiInterface()
        let searchText = hasAnkiCard ? searchModel.ankiExpression : lastSearchString
        
        searcher.browseQuery(expression: searchText) {}
    }
    
    var audioUrl: URL? {
        guard let searchModel = searchModel else {
            return nil
        }
        
        let source = LanguagePodAudioSource()
        return source.url(forTerm: searchModel.groupTerm,
                          andKana: searchModel.kana)
    }
    
    var tags: [String] {
        searchModel?.tags.filter({ $0.count > 0 }) ?? []
    }
    
    var terms: EnumeratedSequence<[TaihenSearchTerm]> {
        guard let terms = searchModel?.terms else {
            return [].enumerated()
        }
        
        return terms.enumerated()
    }
}

protocol AudioSource {
    func url(forTerm term: String, andKana kana: String) -> URL?
}

class LanguagePodAudioSource: AudioSource {
    
    func url(forTerm term: String, andKana kana: String) -> URL? {
        let encodedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let encodedKana = kana.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        
        let langaugePod101BaseUrl = "https://assets.languagepod101.com/dictionary/japanese/audiomp3.php"
        
        if kana.isEmpty {
            let urlString = langaugePod101BaseUrl + "?kana=\(encodedTerm)"

            return URL(string: urlString)
        } else {
            let urlString = langaugePod101BaseUrl + "?kanji=\(encodedTerm)&kana=\(encodedKana)"

            return URL(string: urlString)
        }
    }
}
