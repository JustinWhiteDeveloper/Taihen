import SwiftUI
import TaihenDictionarySupport
import AVFoundation
import LaughingOctoAdventure

private enum Fonts {
    static let kanaFont = Font.system(size: 26.0)
    static let termFont = Font.system(size: 50.0)
}

private enum Sizings {
    static let topAccessoryViewSpacing: CGFloat = 10.0
}

private enum Strings {
    static let copyButtonIcon = "doc.on.doc"
    static let playAudioButtonIcon = "headphones.circle"
    
    static let addButtonIcon = "plus"
    static let reviewKnownCardIcon = "paperplane"
    static let searchButtonIcon = "magnifyingglass"

}

struct YomiTopKanaView: View {
    
    @State var kana: String
    @State var term: String
    
    var body: some View {
        VStack {
            Text(kana)
                .foregroundColor(.black)
                .font(Fonts.kanaFont)
                .textSelection(.enabled)
                .lineLimit(1)
            
            Text(term)
                .foregroundColor(.black)
                .font(Fonts.termFont)
                .textSelection(.enabled)
                .lineLimit(1)
            
        }
    }
}

struct YomiTopAccessoryView: View {
    
    @State var tags: [String]
    @Binding var hasCard: Bool
    @Binding var hasSearched: Bool
    @Binding var isReviewed: Bool
    @State var audioUrl: URL?
    
    var onCopyButtonPressed: () -> Void
    var onPlayAudio: (_ url: URL?) -> Void
    var onAnkiPrompt: () -> Void
    var onAddAnkiCard: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Sizings.topAccessoryViewSpacing) {
            
            TagView(tags: tags)
            
            HStack {
                
                Image(systemName: Strings.copyButtonIcon)
                    .onTapGesture {
                   onCopyButtonPressed()
                }
                .foregroundColor(.black)
                .imageScale(.large)
                .font(Font.title)

                Image(systemName: Strings.playAudioButtonIcon)
                    .onTapGesture {
                    onPlayAudio(audioUrl)
                }
                .foregroundColor(.black)
                .imageScale(.large)
                .font(Font.title)
                
                Image(systemName: Strings.searchButtonIcon)
                    .font(Font.title)
                    .foregroundColor(Color.black)
                    .imageScale(.large)
                    .onTapGesture {
                        onAnkiPrompt()
                    }
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                
                if hasSearched {
                    
                    if hasCard && !isReviewed {
                        Image(systemName: Strings.reviewKnownCardIcon)
                            .font(Font.title)
                            .foregroundColor(Color.black)
                            .imageScale(.large)
                            .onTapGesture {
                                onAnkiPrompt()
                            }
                            .transaction { transaction in
                                transaction.animation = nil
                            }
                        
                    } else if !hasCard {
                        
                        Image(systemName: Strings.addButtonIcon)
                            .font(Font.title)
                            .foregroundColor(Color.black)
                            .imageScale(.large)
                            .onTapGesture {
                                onAddAnkiCard()
                            }
                            .transaction { transaction in
                                transaction.animation = nil
                            }
                    }
                }
            }
        }
    }
}

struct YomiBottomView: View {
    
    @Binding var cardText: String
    @Binding var ankiExpressionText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(cardText)
                .foregroundColor(Color.black)
                .textSelection(.enabled)
            
            Text(ankiExpressionText)
                .foregroundColor(Color.black)
                .textSelection(.enabled)
        }
    }
}
