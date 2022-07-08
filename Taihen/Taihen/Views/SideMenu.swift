import Foundation
import SwiftUI

private enum Sizings {
    static let sideMenuItemSpacing: CGFloat = 20.0
    static let sideMenuHorizontalPadding: CGFloat = 20.0
}

struct SideMenu: View {
    
    @Binding var modes: [ViewMode]
    @Binding var viewMode: ViewMode
    
    var onChangeViewMode: (_ viewMode: ViewMode) -> Void
    
    var body: some View {
        VStack {
            VStack(alignment: .leading,
                   spacing: Sizings.sideMenuItemSpacing) {
                ForEach(modes, id: \.self) { item in
                    HStack {
                        Image(systemName: item.imageName)
                            .foregroundColor(.gray)
                            .imageScale(.large)
                        
                    }
                    .onTapGesture {
                        onChangeViewMode(item)
                    }
                }
            }
            .frame(maxHeight: .infinity)

        }
        .padding(.horizontal,
                 Sizings.sideMenuHorizontalPadding)
        .background(Colors.customGray1)
    }
}
