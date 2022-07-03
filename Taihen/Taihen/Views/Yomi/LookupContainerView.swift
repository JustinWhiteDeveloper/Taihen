import Foundation
import SwiftUI
import TaihenDictionarySupport

struct LookupContainerView: View {

    @State var text = ""
        
    var body: some View {
        
        VStack(alignment: .leading) {
            Spacer()
            
            YomiSearchBar(text: $text)
                .onChange(of: text) { newValue in
                    NotificationCenter.default.post(name: Notification.Name.onSelectionChange,
                                                    object: text)
                }
            
            // Share search view between container view and reader preview
            YomiSearchView()
                .background(Colors.customGray1)
                .padding()
        }
    }
}
