import SwiftUI
import TaihenDictionarySupport
import AVFoundation
import LaughingOctoAdventure

private enum Fonts {
    static let kanaFont = Font.system(size: 26.0)
    static let termFont = Font.system(size: 50.0)
}

struct YomiTopView: View {
    
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
