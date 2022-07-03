import Foundation
import SwiftUI

struct SideMenu: View {
    
    @Binding var modes: [ViewMode]
    @Binding var viewMode: ViewMode
    
    var onChangeViewMode: (_ viewMode:ViewMode) -> Void
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20.0) {
                ForEach(modes, id: \.self) { item in
                    HStack {
                        Image(systemName: item.imageName)
                            .foregroundColor(.gray)
                            .imageScale(.large)
                        Text(item.rawValue)
                            .foregroundColor(.gray)
                            .font(.headline)
                    }
                    .onTapGesture {
                        onChangeViewMode(item)
                    }
                }
            }
            .frame(maxHeight: .infinity)

        }
        .padding(.horizontal, 20.0)
        .background(Colors.customGray2)
    }
}
