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
                    
                    if let searchModel = viewModel.searchModel {
                        
                        ScrollView {
                            
                            VStack(alignment: .leading) {
 
                                HStack {
                                    
                                    YomiTopKanaView(kana: searchModel.kana,
                                                    term: searchModel.groupTerm)

                                    YomiTopAccessoryView(tags: viewModel.tags,
                                                         hasCard: $viewModel.hasAnkiCard,
                                                         hasSearched: $viewModel.didSearch,
                                                         isReviewed: $viewModel.isReviewed,
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
                                
                                ForEach(Array(viewModel.terms),
                                        id: \.offset) { resultIndex, searchResultItem in
                                    
                                    HStack {
                                        Text(String("\(resultIndex + 1):"))
                                            .font(Fonts.arial)
                                            .foregroundColor(.black)

                                        TagView(tags: searchResultItem.filteredMeaningTags)
                                    }
                                    
                                    Text(searchResultItem.meaningDescription)
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
