import Foundation
import SwiftUI
import TaihenDictionarySupport

struct LookupView: View {

    @State var text = ""
        
    var body: some View {
        
        VStack(alignment: .leading) {
            Spacer()
            
            YomiSearchBar(text: $text)
            
            YomiSearchView(parentValue: $text)
                    .padding()
                    .background(Colors.customGray1)
            
        }
    }
}
