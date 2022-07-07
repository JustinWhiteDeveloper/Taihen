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
    @Published var hasCard: Bool = false
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

        // Delay to prevent blocking layout
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            
            let audioSource = LanguagePodAudioSource()
            
            guard let firstTerm = self.searchModel,
                  let url = audioSource.url(forTerm: firstTerm.groupTerm,
                                            andKana: firstTerm.kana),
                  FeatureManager.instance.autoplayAudio else {
                return
            }
                 
            self.playAudioUrl(url)
        }
    }
    
    func playAudioUrl(_ url: URL?) {
        
        guard let url = url else {
            return
        }
        
        do {
            let audioData = try Data(contentsOf: url)
            
            if audioData.count >= Sizings.maximumAudioSize {
                return
            }
            
            let tmpFileURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent("audio" + NSUUID().uuidString)
                                .appendingPathExtension("mp3")
            
            let wasFileWritten = (try? audioData.write(to: tmpFileURL, options: [.atomic])) != nil

            if wasFileWritten {
                self.player = AVPlayer(url: tmpFileURL)
                self.player?.volume = 1.0
                self.player?.play()
            }
        } catch {
            print(String(describing: error))
        }
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
                
                self.onSearchFinished()
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

    func onSearchFinished() {
        
        guard let firstTerm = searchModel else {
            return
        }
        
        let term = firstTerm.groupTerm
        let kana = firstTerm.kana
        
        let furiganaFormatter = ConcreteFuriganaFormatter()
        let result = furiganaFormatter.formattedString(fromKanji: term, andHiragana: kana)
        
        cardText = result

        let searcher = ConcreteAnkiInterface()
        
        //If contains hiragana and kanji then use *contains*
        let expressionPart = (result.containsKanji && result.containsHiragana) ? "*\(result)*" : result
        
        let ankiExpression = "\"expression:\(expressionPart)\" OR \"Focus:\(term)\" OR \"Meaning:\(term)\""
        
        ankiExpressionText = ankiExpression
        
        searcher.findCards(expression: ankiExpression) { result in
            
            guard let result = result else {
                self.didSearch = false
                return
            }
            
            if let error = result.error {
                print(error)
                self.didSearch = false
                return
            }
            
            print(result.result)
            
            if result.result.count > 0 {
                searcher.getCardInfo(values: result.result) { result in
                    
                    guard let result = result else {
                        self.hasCard = false
                        self.didSearch = true

                        return
                    }
                    
                    if let error = result.error {
                        print(error)
                        self.hasCard = false
                        self.didSearch = true

                        return
                    }
                    
                    if let firstItem = result.result.map({ $0.due }).sorted().first {
                        self.isReviewed = firstItem < 10000
                    }
                    
                    self.hasCard = true
                    self.didSearch = true

                }
                
            } else {
                self.hasCard = false
                self.didSearch = true
            }
        }
        
        autoplayAudioIfAvailable()

    }
    
    func onCopyButtonPressed() {
        
        guard let firstTerm = searchModel else {
            return
        }
        
        SharedManagedDataController
            .dictionaryInstance
            .searchValue(value: firstTerm.groupTerm) { finished, _, model, _ in
            
            guard finished,
                    let firstModel = self.searchModel else {
                return
            }
            
            let meanings = firstModel.terms.map({ $0.meanings })
                
            let clipboardFormatter = YomichanClipboardFormatter()
            let copyText = clipboardFormatter.formatForTerms(meanings)
            
            CopyboardEnabler.enabled = false
            
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString( copyText, forType: .string)
                            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                CopyboardEnabler.enabled = true
            }
        }
    }
    
    func onAnkiPromptButtonPressed() {
        let searcher = ConcreteAnkiInterface()
        let searchText = hasCard ? ankiExpressionText : lastSearchString
        
        searcher.browseQuery(expression: searchText) {}
    }
    
    var audioUrl: URL? {
        guard let firstTerm = searchModel else {
            return nil
        }
        
        let source = LanguagePodAudioSource()
        return source.url(forTerm: firstTerm.groupTerm,
                          andKana: firstTerm.kana)
    }
}
