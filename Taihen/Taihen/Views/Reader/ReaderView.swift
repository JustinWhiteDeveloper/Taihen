import Foundation
import SwiftUI

private enum Sizings {
    
    static let dictionaryPreviewMinimumSize: CGFloat = 300.0
    static let dictionaryPreviewMaximumSize: CGFloat = 600.0
}

struct ReaderView: View {

    @StateObject var viewModel: ReaderViewModel = ReaderViewModel()
        
    var body: some View {
        
        ZStack {
            
            HSplitView {
                CustomizableTextEditor(text: $viewModel.text,
                                       scrollPercentage: $viewModel.scrollPercentage)
                
                YomiSearchView()
                    .background(Colors.customGray1)
                    .frame(minWidth: Sizings.dictionaryPreviewMinimumSize,
                           maxWidth: Sizings.dictionaryPreviewMaximumSize)
            }
            .onAppear {
                viewModel.onAppear()
            }
            
            HStack(alignment: .top) {
                Spacer()
                
                VStack(alignment: .trailing) {

                    if viewModel.scrollPercentage > 0 {
                        Text(formattedScrollPercentage)
                            .foregroundColor(Color.black)
                        
                    }

                    Spacer()
                }
            }
        }
    }
    
    var formattedScrollPercentage: String {
        String(format: "%.2f", viewModel.scrollPercentage * 100) + "%"
    }
}
