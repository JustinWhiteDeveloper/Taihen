import SwiftUI
import TaihenDictionarySupport
import AVFoundation
import LaughingOctoAdventure

private enum Fonts {
    static let kanaFont = Font.system(size: 26.0)
    static let termFont = Font.system(size: 50.0)
    
    static let ankiPromptFont = Font.system(size: 30)
}

private enum Sizings {
    static let topAccessoryViewSpacing: CGFloat = 10.0
}

private enum Strings {
    static let copyButtonTitle = NSLocalizedString("Copy", comment: "")
    static let playAudioButtonTitle = NSLocalizedString("Play Audio", comment: "")
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
            
            Text(term)
                .foregroundColor(.black)
                .font(Fonts.termFont)
                .textSelection(.enabled)
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

    var body: some View {
        VStack(alignment: .leading, spacing: Sizings.topAccessoryViewSpacing) {
            
            TagView(tags: tags)
            
            HStack {
                
                Button(Strings.copyButtonTitle) {
                   onCopyButtonPressed()
                }
                .foregroundColor(.black)
                
                Button(Strings.playAudioButtonTitle) {
                    onPlayAudio(audioUrl)
                }
                .foregroundColor(.black)
                
                if hasSearched {
                    Text((hasCard ? (isReviewed ? "" : "^") : "+"))
                        .font(Fonts.ankiPromptFont)
                        .foregroundColor(Color.black)
                        .onTapGesture {
                            onAnkiPrompt()
                        }
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                }
            }
        }
    }
}

struct YomiBottomView: View {
    
    @State var cardText: String
    @State var ankiExpressionText: String
    
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
