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
                    
                    if let firstTerm = viewModel.searchModel {
                        
                        ScrollView {
                            
                            VStack(alignment: .leading) {
 
                                HStack {
                                    
                                    YomiTopKanaView(kana: firstTerm.kana,
                                                    term: firstTerm.groupTerm)

                                    YomiTopAccessoryView(tags: firstTerm.tags.filter({ $0.count > 0 }),
                                                         didSearch: viewModel.didSearch,
                                                         hasCard: viewModel.hasCard,
                                                         isReviewed: viewModel.isReviewed,
                                                         audioUrl: viewModel.audioUrl,
                                                         onCopyButtonPressed: {
                                        viewModel.onCopyButtonPressed()

                                    },
                                                         onPlayAudio: { url in
                                        viewModel.playAudioUrl(url)

                                    },
                                                         onAnkiPrompt: {
                                        viewModel.onAnkiPromptButtonPressed()
                                    })
                                }
                                .padding(.top)
                                
                                ForEach(Array(firstTerm.terms.enumerated()), id: \.offset) { index1, term in
                                    
                                    HStack {
                                        Text(String("\(index1 + 1):"))
                                            .font(Fonts.arial)
                                            .foregroundColor(.black)

                                        TagView(tags: term.meaningTags.filter({$0.count > 0}))
                                    }
                                    
                                    Text(YomichanMeaningFormatter().meaningDescription(meanings: term.meanings))
                                        .foregroundColor(.black)
                                        .font(Fonts.arial)
                                        .textSelection(.enabled)
                          
                                    Divider()
                                }

                                YomiBottomView(cardText: viewModel.cardText,
                                               ankiExpressionText: viewModel.ankiExpressionText)
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

protocol MeaningFormatter {
    func meaningDescription(meanings: [String]) -> String
}

class YomichanMeaningFormatter: MeaningFormatter {
    func meaningDescription(meanings: [String]) -> String {
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
