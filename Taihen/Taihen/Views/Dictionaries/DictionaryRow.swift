import SwiftUI

private enum Strings {
    static let activeToggle = NSLocalizedString("Active", comment: "")
    static let deleteDictionaryIcon = NSLocalizedString("CancelIcon", comment: "")
    static let reorderIcon = NSLocalizedString("MoveIcon", comment: "")
}

private enum Sizings {
    static let deleteButtonVerticalPadding: CGFloat = 10.0
    static let deleteButtonSize = CGSize(width: 34.0, height: 34.0)
    static let deleteButtonCornerRadius: CGFloat = 12.0
    
    static let reorderButtonSize = CGSize(width: 24.0, height: 24.0)
}

struct DictionaryRow: View {

    @ObservedObject var viewModel: DictionaryRowViewModel
    
    var body: some View {
        HStack {
            Text(viewModel.model.name)
                .foregroundColor(.black)
                .font(.title)
                .bold()
            
            Spacer()
            
            Toggle(Strings.activeToggle, isOn: $viewModel.model.active)
                .padding()
                .foregroundColor(.black)
                .onChange(of: viewModel.model.active) { newValue in
                    viewModel.onChangeOfActiveState(newValue: newValue)
                }
            
            ZStack {
                Button("   ", action: {
                    viewModel.onDeleteRow()
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .buttonStyle(PlainButtonStyle())
                
                Image(Strings.deleteDictionaryIcon)
                    .renderingMode(.original)
                    .allowsHitTesting(false)

            }
            .padding(.vertical, Sizings.deleteButtonVerticalPadding)
            .frame(width: Sizings.deleteButtonSize.width,
                   height: Sizings.deleteButtonSize.height)
            .cornerRadius(Sizings.deleteButtonCornerRadius)
            
            ZStack {
                Button("",
                       action: {
                    
                })
                .buttonStyle(PlainButtonStyle())

                Image(Strings.reorderIcon)
                    .renderingMode(.original)
                
            }
            .frame(width: Sizings.reorderButtonSize.width,
                   height: Sizings.reorderButtonSize.height)
        }
    }
}
