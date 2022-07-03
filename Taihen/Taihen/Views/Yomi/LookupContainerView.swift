import Foundation
import SwiftUI
import TaihenDictionarySupport

struct LookupContainerView: View {

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
