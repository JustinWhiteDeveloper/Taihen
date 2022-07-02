import SwiftUI

struct CustomizableLoadingView: View {
    
    @Binding var text: String
    
    var body: some View {
        VStack {
            
            ZStack {
                ProgressView(text)
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                    .padding(.all, 10.0)
            }
            .background(Color.gray)
            .frame(height: 50.0, alignment: .center)


        }
        .frame(maxWidth: .infinity,
               maxHeight: .infinity)
    }
}
