import SwiftUI

private enum Sizings {
    static let loadingPadding: CGFloat = 10.0
    static let loaderSizeLength: CGFloat = 50.0
}

struct CustomizableLoadingView: View {
    
    @Binding var text: String
    
    var body: some View {
        VStack {
            
            ZStack {
                ProgressView(text)
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                    .padding(.all,
                             Sizings.loadingPadding)
            }
            .background(Color.gray)
            .frame(height: Sizings.loadingPadding,
                   alignment: .center)


        }
        .frame(maxWidth: .infinity,
               maxHeight: .infinity)
    }
}
