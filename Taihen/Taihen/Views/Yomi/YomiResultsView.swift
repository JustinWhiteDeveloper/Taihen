import Foundation
import SwiftUI
import TaihenDictionarySupport
import AVFoundation
import LaughingOctoAdventure

private enum Strings {
    static let copyButtonTitle = NSLocalizedString("Copy", comment: "")
    static let playAudioButtonTitle = NSLocalizedString("Play Audio", comment: "")
}

struct ItemView: View {
    
    @State var search = ""
    @State var text = ""
    @State var term = ""
    @State var kana = ""
    @State var terms: [TaihenCustomDictionaryTerm] = []
    @State var tags: [String] = []
    @State var audioUrl: URL?
    
    @State var player: AVPlayer?
    
    @State var didSearch: Bool = false

    @State var hasCard: Bool = false
    @State var isReviewed: Bool = false

    @State var cardText: String = ""

    @State var ankiExpressionText: String = ""

    var body: some View {
        
        Spacer()
        
        HStack {
            VStack {
                Text(kana)
                    .foregroundColor(.black)
                    .font(Font.system(size: 26))
                    .textSelection(.enabled)
                
                Text(term)
                    .foregroundColor(.black)
                    .font(Font.system(size: 50))
                    .textSelection(.enabled)

            }
            
            HStack {
                TagView(tags: tags.filter({$0.count > 0}))
                
                Button(Strings.copyButtonTitle) {
                    SharedManagedDataController.dictionaryInstance.termDescriptionToClipboard(term: term)
                }
                .foregroundColor(.black)

                if FeatureManager.instance.audioEnabled {
                    Button(Strings.playAudioButtonTitle) {
                        
                        if let url = audioUrl {
                            print("playing \(url)")

                            let playerItem = AVPlayerItem(url: url)

                            player = AVPlayer(playerItem:playerItem)
                            player?.volume = 1.0
                            player?.play()

                        }
                        
                    }
                    .foregroundColor(.black)
                }
                
                if didSearch {
                    Text((hasCard ? ( isReviewed ? "" : "^") : "+"))
                        .font(Font.system(size: 30))
                        .foregroundColor(Color.black)
                        .onTapGesture {
                            let searcher = ConcreteAnkiInterface()
                            
                            let searchText = hasCard ? ankiExpressionText : search
                            
                            searcher.browseQuery(expression: searchText) {}
                        }
                }
            }
        }
        
        ForEach(Array(terms.enumerated()), id: \.offset) { index1, term in
            
            HStack {
                Text(String("\(index1 + 1):"))
                    .font(Font.custom("Arial", size: FeatureManager.instance.dictionaryTextSize))
                    .foregroundColor(.black)

                TagView(tags: term.meaningTags.filter({$0.count > 0}))
            }
            
            Text(term.meaningDescription)
                .foregroundColor(.black)
                .font(Font.custom("Arial", size: FeatureManager.instance.dictionaryTextSize))
                .textSelection(.enabled)
  

            Divider()
        }
        
        Spacer()
            .onAppear {
                
                //Algorithm needed
                
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
                        didSearch = false
                        return
                    }
                    
                    if let error = result.error {
                        print(error)
                        didSearch = false
                        return
                    }
                    
                    print(result.result)
                    
                    
                    if result.result.count > 0 {
                        searcher.getCardInfo(values: result.result) { result in
                            
                            guard let result = result else {
                                hasCard = false
                                didSearch = true

                                return
                            }
                            
                            if let error = result.error {
                                print(error)
                                hasCard = false
                                didSearch = true

                                return
                            }
                            
                            
                            if let firstItem = result.result.map({ $0.due}).sorted().first {
                                
                                isReviewed = firstItem < 10000
                            }
                            
                            hasCard = true
                            didSearch = true

                        }
                        
                    } else {
                        hasCard = false
                        didSearch = true
                    }
                    
                }
            }
        
        Text(cardText)
            .foregroundColor(Color.black)
            .textSelection(.enabled)
        
        Text(ankiExpressionText)
            .foregroundColor(Color.black)
            .textSelection(.enabled)
        
        Text("\(search)\t\(term)")
            .foregroundColor(Color.black)
            .textSelection(.enabled)

    }
}

extension TaihenCustomDictionaryTerm {
    
    var meaningDescription: String {
        if meanings.count == 1 {
            return meanings.first ?? ""
            
        } else {
            
            var text = ""
            
            for (index, meaning) in meanings.enumerated() {
                text += "• " + meaning
                
                if index < meanings.count - 1 {
                    text += "\n"
                }
            }
            
            return text
        }
    }
}

struct TagPill: View {
    
    @State var text: String
    @State var color: Color = Color.red

    var body: some View {
        
        ZStack {
            Text(text)
                .bold()
                .foregroundColor(.white)
        }
        .padding(.all, 8.0)
        .background(color)
        .cornerRadius(8.0)
    }
}

struct TagView: View {
    
    @State var tags: [String] = []
    
    var body: some View {
        
        HStack {
                        
            ForEach(Array(tags.enumerated()), id: \.offset) { index1, text in
                TagPill(text: text,
                        color: YomiChanTagManager.colorOfTag(name: text))
            }
        }
    }
}

struct YomiResultsView: View {
    
    @State var search: String
    @State var selectedTerms: [[TaihenDictionaryViewModel]] = []

    var body: some View {
        ScrollView {
            
            VStack(alignment: .leading) {
                ForEach(Array(selectedTerms.enumerated()), id: \.offset) { index, termItem in
                                    
                    ForEach(Array(termItem.enumerated()), id: \.offset) { index2, item in
                    
                        ItemView(search: search,
                                 term: item.groupTerm,
                                 kana: item.kana,
                                 terms: item.terms,
                                 tags: item.tags,
                                 audioUrl: item.audioUrl)
                        
                        Spacer()
                    }
                }
            }
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
