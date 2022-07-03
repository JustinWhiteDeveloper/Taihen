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
