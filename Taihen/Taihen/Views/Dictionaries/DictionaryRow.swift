import SwiftUI

private enum Strings {
    static let activeToggle = NSLocalizedString("Active", comment: "")
    static let deleteDictionaryIcon = "folder.fill.badge.minus"
    static let reorderIcon = "chevron.up.chevron.down"
}

private enum Sizings {
    static let rightIconsHorizontalPadding: CGFloat = 10.0
}

struct DictionaryRow: View {

    @ObservedObject var viewModel: DictionaryRowViewModel
    
    var body: some View {
        HStack {
            Text(viewModel.model.name)
                .foregroundColor(.black)
                .font(.title2)
                .padding(.horizontal, Sizings.rightIconsHorizontalPadding)

            Spacer()

            Toggle(Strings.activeToggle, isOn: $viewModel.model.active)
                .padding()
                .foregroundColor(.black)
                .padding(.horizontal, Sizings.rightIconsHorizontalPadding)
                .onChange(of: viewModel.model.active) { newValue in
                    viewModel.onChangeOfActiveState(newValue: newValue)
                }
            
            Image(systemName: Strings.deleteDictionaryIcon)
                .imageScale(.large)
                .font(Font.title)
                .onTapGesture {
                    viewModel.onDeleteRow()
                }
                .padding(.horizontal, Sizings.rightIconsHorizontalPadding)

            Image(systemName: Strings.reorderIcon)
                .imageScale(.large)
                .font(Font.title)
                .padding(.horizontal, Sizings.rightIconsHorizontalPadding)

        }
        .background(Colors.customGray2)
    }
}
