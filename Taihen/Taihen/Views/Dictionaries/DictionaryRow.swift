import SwiftUI

private enum Strings {
    static let activeToggle = "Active"
    static let deleteDictionaryIcon = "CancelIcon"
    static let reorderIcon = "MoveIcon"
}

private enum Sizings {
    static let deleteButtonVerticalPadding: CGFloat = 10.0
    static let deleteButtonSize = CGSize(width: 34.0, height: 34.0)
    static let deleteButtonCornerRadius: CGFloat = 12.0
    
    static let reorderButtonSize = CGSize(width: 24.0, height: 24.0)
}

struct DictionaryRow: View {

    @State var model: DictionaryViewModel
    var onDelete: (_ name: String) -> Void
    
    var body: some View {
        HStack {
            Text(model.name)
                .foregroundColor(.black)
                .font(.title)
                .bold()
            
            Spacer()
            
            Toggle(Strings.activeToggle, isOn: $model.active)
                .padding()
                .foregroundColor(.black)
                .onChange(of: model.active) { newValue in
                    SharedManagedDataController.dictionaryInstance.updateDictionaryActive(viewModel: model.managedModel, active: newValue)
                }
            
            ZStack {
                Button("   ",  action: {
                    onDelete(model.name)
                })
                .frame(maxWidth: .infinity,maxHeight: .infinity)
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
