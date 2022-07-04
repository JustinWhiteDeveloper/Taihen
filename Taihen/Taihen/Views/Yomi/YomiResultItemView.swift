import SwiftUI
import TaihenDictionarySupport
import AVFoundation
import LaughingOctoAdventure

private enum Fonts {
    static let kanaFont = Font.system(size: 26.0)
    static let termFont = Font.system(size: 50.0)
    
    static let ankiPromptFont = Font.system(size: 30)
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
    @State var didSearch: Bool
    @State var hasCard: Bool
    @State var isReviewed: Bool
    @State var audioUrl: URL?
    
    var onCopyButtonPressed: () -> Void
    var onPlayAudio: (_ url: URL?) -> Void
    var onAnkiPrompt: () -> Void

    var body: some View {
        HStack {
            TagView(tags: tags)
            
            Button(Strings.copyButtonTitle) {
               onCopyButtonPressed()
            }
            .foregroundColor(.black)

            Button(Strings.playAudioButtonTitle) {
                onPlayAudio(audioUrl)
            }
            .foregroundColor(.black)
            
            if didSearch {
                Text((hasCard ? ( isReviewed ? "" : "^") : "+"))
                    .font(Fonts.ankiPromptFont)
                    .foregroundColor(Color.black)
                    .onTapGesture {
                        onAnkiPrompt()
                    }
            }
        }
    }
}

struct YomiBottomView: View {
    
    @State var cardText: String
    @State var ankiExpressionText: String
    @State var lastSearchString: String
    @State var groupTerm: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(cardText)
                .foregroundColor(Color.black)
                .textSelection(.enabled)
            
            Text(ankiExpressionText)
                .foregroundColor(Color.black)
                .textSelection(.enabled)
            
            Text("\(lastSearchString)\t\(groupTerm)")
                .foregroundColor(Color.black)
                .textSelection(.enabled)
        }
    }
}
