import Foundation
import SwiftUI
import TaihenDictionarySupport
import AVFoundation
import LaughingOctoAdventure

private enum Strings {
    static let loadingText = NSLocalizedString("Loading", comment: "")
    static let noResultsText = NSLocalizedString("No results", comment: "")
}

private enum Fonts {
    static let arial = Font.custom("Arial", size: FeatureManager.instance.dictionaryTextSize)
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
 
                                HStack {
                                    
                                    YomiTopKanaView(kana: firstTerm.kana,
                                                    term: firstTerm.groupTerm)

                                    YomiTopAccessoryView(tags: firstTerm.tags.filter({ $0.count > 0 }),
                                                         didSearch: viewModel.didSearch,
                                                         hasCard: viewModel.hasCard,
                                                         isReviewed: viewModel.isReviewed,
                                                         audioUrl: firstTerm.audioUrl) {
                                        viewModel.onCopyButtonPressed()

                                    } onPlayAudio: { url in
                                        viewModel.playAudioUrl(url)

                                    } onAnkiPrompt: {
                                        viewModel.onAnkiPromptButtonPressed()
                                    }
                                }
                                .padding(.top)
                                
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

                                YomiBottomView(cardText: viewModel.cardText,
                                               ankiExpressionText: viewModel.ankiExpressionText,
                                               lastSearchString: viewModel.lastSearchString,
                                               groupTerm: viewModel.firstTerm?.groupTerm ?? "")
                                .padding(.vertical)

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
