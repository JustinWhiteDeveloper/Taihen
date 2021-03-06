import SwiftUI

private enum Strings {
    static let searchTextPreview = NSLocalizedString("Search here", comment: "")
}

private enum Sizings {
    static let searchBarCornerRadius: CGFloat = 16.0
    static let searchBarHorizontalPadding: CGFloat = 40.0
    static let searchBarMaxWidth: CGFloat = 200.0
}

struct YomiSearchBar: View {
    
    @Binding var text: String
    
    var body: some View {
        TextField(Strings.searchTextPreview, text: $text)
            .foregroundColor(.black)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .cornerRadius(Sizings.searchBarCornerRadius)
            .padding(.horizontal, Sizings.searchBarHorizontalPadding)
            .frame(maxWidth: Sizings.searchBarMaxWidth,
                   alignment: .leading)
    }
}
