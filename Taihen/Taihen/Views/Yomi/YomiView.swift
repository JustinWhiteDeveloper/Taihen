import Foundation
import SwiftUI
import TaihenDictionarySupport

private enum Strings {
    static let loadingText = "Loading"
    static let searchTextPreview = "Search here"
}

struct YomiView: View {

    @State var text = ""
    @State var oldText = ""

    @State var lookupTime: Double = 0
    @State var isLoading: Bool = false
    
    @State var selectedTerms: [[TaihenDictionaryViewModel]] = []
    
    @State var loadingText = Strings.loadingText

    var body: some View {
        
        VStack(alignment: .leading) {
            Spacer()
            
            TextField(Strings.searchTextPreview, text: $text)
                .foregroundColor(.black)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .cornerRadius(16)
                .padding(.horizontal, 40.0)
                .frame(maxWidth: 200.0, alignment: .leading)
            
            YomiPreviewView(parentValue: $text)
                .padding()
                .background(Colors.customGray1)
            
        }
    }
}
