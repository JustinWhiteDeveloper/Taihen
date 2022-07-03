import Foundation
import SwiftUI
import TaihenDictionarySupport
import AVFoundation
import LaughingOctoAdventure

private enum Strings {
    static let loadingText = NSLocalizedString("Loading", comment: "")
    static let noResultsText = NSLocalizedString("No results", comment: "")
    static let copyButtonTitle = NSLocalizedString("Copy", comment: "")
    static let playAudioButtonTitle = NSLocalizedString("Play Audio", comment: "")
}

private enum Fonts {
    static let arial = Font.custom("Arial", size: FeatureManager.instance.dictionaryTextSize)
    static let kanaFont = Font.system(size: 26.0)
    static let termFont = Font.system(size: 50.0)
    static let ankiPromptFont = Font.system(size: 30)
}


class YomiSearchViewModel: ObservableObject {
    @Published var hasBooted = false
    @Published var lastResultCount = 0

    @Published var isLoading = true
    @Published var finishedLoadingDelay = true

    @Published var lookupTime: Double = 0

    @Published var selectedTerms: [[TaihenDictionaryViewModel]] = []
    @Published var firstTerm: TaihenDictionaryViewModel?

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
    
    func onLoad() {
        SharedManagedDataController.tagManagementInstance.reloadTags()
        SharedManagedDataController.dictionaryInstance.reloadDictionaries()
    }
    
    func autoplayAudioIfAvailable() {

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            
            guard let url = self.firstTerm?.audioUrl,
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
            
            // Too long audio
            if audioData.count >= 52288 {
                return
            }
            
            let tmpFileURL = URL(fileURLWithPath:NSTemporaryDirectory())
                .appendingPathComponent("audio" + NSUUID().uuidString)
                                .appendingPathExtension("mp3")
            
            let wasFileWritten = (try? audioData.write(to: tmpFileURL, options: [.atomic])) != nil

            if wasFileWritten{
                self.player = AVPlayer(url: tmpFileURL)
                self.player?.volume = 1.0
                self.player?.play()
                
            } else {
                print("File was NOT Written")
            }
        }
        catch {
            print(String(describing: error))
        }
    }
    
    func onPasteChange() {
        guard FeatureManager.instance.clipboardReadingEnabled,
           let latestItem = NSPasteboard.general.clipboardContent()?.trimingTrailingSpaces(), CopyboardEnabler.enabled, latestItem.count < 100 else {
            return
        }
            
        //Prevent accidently copying english text
        if latestItem.containsValidJapaneseCharacters == false || latestItem.contains("expression") {
            return
        }
    
        onSearch(value: latestItem)
    }
    
    func onSearch(value: String) {
        
        print(value + " " + hasBooted.description)
        
        if self.lastSearch == value {
            print("duplicate")
            return
        }


        self.lastSearch = value

        self.lastSearchString = self.lastSearch
        self.hasBooted = true
        self.isLoading = true
        
        // Reset and add timer
        self.finishedLoadingDelay = false
        self.lookupTime = 0
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.finishedLoadingDelay = true
        }
        
        SharedManagedDataController.dictionaryInstance.searchValue(value: value) { finished, timeTaken, selectedTerms, resultCount in
            
            DispatchQueue.main.async {
                self.lookupTime = timeTaken
                self.isLoading = false
                self.selectedTerms = selectedTerms
                self.lastResultCount = resultCount
                self.finishedLoadingDelay = false
                self.firstTerm = selectedTerms.first?.first
            }

            
            self.onSearchFinished()
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
        
        autoplayAudioIfAvailable()

        let term = firstTerm?.groupTerm ?? ""
        let kana = firstTerm?.kana ?? ""
        
        let furiganaFormatter = ConcreteFuriganaFormatter()
        let result = furiganaFormatter.formattedString(fromKanji: term, andHiragana: kana)
        
        cardText = result

        let searcher = ConcreteAnkiInterface()
        
        //If contains hiragana and kanji then use *contains*
        let expressionPart = (result.containsKanji && result.containsHiragana) ? "*\(result)*" : result
        
        let ankiExpression = "\"expression:\(expressionPart)\" OR \"Focus:\(term)\" OR \"Meaning:\(term)\""
        
        ankiExpressionText = ankiExpression

        print("here")
        
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
                    
                    if let firstItem = result.result.map({ $0.due}).sorted().first {
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
    }
    
    func onCopyButtonPressed() {
        SharedManagedDataController.dictionaryInstance.termDescriptionToClipboard(term: firstTerm?.groupTerm ?? "")
    }
    
    func onAnkiPromptButtonPressed() {
        let searcher = ConcreteAnkiInterface()
        let searchText = hasCard ? ankiExpressionText : lastSearchString
        
        searcher.browseQuery(expression: searchText) {}
    }
}

struct YomiSearchView: View {

    @StateObject var viewModel: YomiSearchViewModel = YomiSearchViewModel()
    
    var body: some View {
        
        VStack {
            
            if viewModel.hasBooted == false {
                Color.clear
            } else {

                if viewModel.isLoading {
                    
                    if viewModel.finishedLoadingDelay {
                        CustomizableLoadingView(text: $viewModel.loadingText)
                    } else {
                        Color.clear
                    }
                    
                } else {
                    
                    if let firstTerm = viewModel.firstTerm {
                        
                        ScrollView {
                            
                            VStack(alignment: .leading) {
                                Spacer()
 
                                HStack {
                                    
                                    YomiTopView(kana: firstTerm.kana,
                                                term: firstTerm.groupTerm)

                                    HStack {
                                        TagView(tags: firstTerm.tags.filter({$0.count > 0}))
                                        
                                        Button(Strings.copyButtonTitle) {
                                            viewModel.onCopyButtonPressed()
                                        }
                                        .foregroundColor(.black)

                                        Button(Strings.playAudioButtonTitle) {
                                            
                                            viewModel.playAudioUrl(firstTerm.audioUrl)
                                        }
                                        .foregroundColor(.black)
                                        
                                        if viewModel.didSearch {
                                            Text((viewModel.hasCard ? ( viewModel.isReviewed ? "" : "^") : "+"))
                                                .font(Fonts.ankiPromptFont)
                                                .foregroundColor(Color.black)
                                                .onTapGesture {
                                                    viewModel.onAnkiPromptButtonPressed()
                                                }
                                        }
                                    }
                                }
                                
                                ForEach(Array(firstTerm.terms.enumerated()), id: \.offset) { index1, term in
                                    
                                    HStack {
                                        Text(String("\(index1 + 1):"))
                                            .font(Fonts.arial)
                                            .foregroundColor(.black)

                                        TagView(tags: term.meaningTags.filter({$0.count > 0}))
                                    }
                                    
                                    Text(term.meaningDescription)
                                        .foregroundColor(.black)
                                        .font(Fonts.arial)
                                        .textSelection(.enabled)
                          
                                    Divider()
                                }
                                
                                Spacer()
                                
                                Text(viewModel.cardText)
                                    .foregroundColor(Color.black)
                                    .textSelection(.enabled)
                                
                                Text(viewModel.ankiExpressionText)
                                    .foregroundColor(Color.black)
                                    .textSelection(.enabled)
                                
                                Text("\(viewModel.lastSearchString)\t\(viewModel.firstTerm?.groupTerm ?? "")")
                                    .foregroundColor(Color.black)
                                    .textSelection(.enabled)

                                
                                Spacer()
                            }
                            .padding()
                        }

                    } else {
                        
                        ZStack {
                            Color.clear
                            Text(Strings.noResultsText)
                                .foregroundColor(Color.black)
                                .padding()
                        }
                    }
                    
                    Text(viewModel.lookupTime.description)
                        .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            viewModel.onLoad()
        }
        .onPasteboardChange {
            viewModel.onPasteChange()
        }
    }

}

extension TaihenDictionaryViewModel {
    
    var audioUrl: URL? {
        let encodedTerm = groupTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let encodedKana = kana.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        
        if kana.isEmpty {
            let urlString = "https://assets.languagepod101.com/dictionary/japanese/audiomp3.php?kana=\(encodedTerm)"

            return URL(string: urlString)
        } else {
            let urlString = "http://assets.languagepod101.com/dictionary/japanese/audiomp3.php?kanji=\(encodedTerm)&kana=\(encodedKana)"

            return URL(string: urlString)
        }
    }
}
