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

    @Published var didAnkiSearchForCurrentTerm: Bool = false
    @Published var hasAnkiCardForLastSearch: Bool = false
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
                        
            guard let url = self.searchModel?.audioUrl,
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
        
        guard let searchModel = results.searchModel else {
            return
        }
        
        cardText = searchModel.furiganaTerm
        
        let ankiExpression = searchModel.ankiExpression
        ankiExpressionText = ankiExpression
    
        let searcher = ConcreteAnkiInterface()
        searcher.findCards(expression: ankiExpression) { result in
            
            guard let result = result else {
                self.didAnkiSearchForCurrentTerm = false
                return
            }
            
            if let error = result.error {
                print(error)
                self.didAnkiSearchForCurrentTerm = false
                return
            }
            
            print(result.result)
            
            if result.result.count > 0 {
                searcher.getCardInfo(values: result.result) { result in
                    
                    guard let result = result else {
                        self.hasAnkiCardForLastSearch = false
                        self.didAnkiSearchForCurrentTerm = true

                        return
                    }
                    
                    if let error = result.error {
                        print(error)
                        self.hasAnkiCardForLastSearch = false
                        self.didAnkiSearchForCurrentTerm = true

                        return
                    }
                    
                    if let firstItem = result.result
                        .map({ $0.due })
                        .sorted()
                        .first {
                        
                        self.isReviewed = firstItem < Sizings.reviewAsKnownSize
                    }
                    
                    self.hasAnkiCardForLastSearch = true
                    self.didAnkiSearchForCurrentTerm = true

                }
                
            } else {
                self.hasAnkiCardForLastSearch = false
                self.didAnkiSearchForCurrentTerm = true
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
        let searcher = ConcreteAnkiInterface()
        let searchText = hasAnkiCardForLastSearch ? ankiExpressionText : lastSearchString
        
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
