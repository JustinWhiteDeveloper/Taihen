import Foundation
import SwiftUI
import TaihenDictionarySupport

private enum Strings {
    static let title = NSLocalizedString("Dictionaries", comment: "")
    static let defaultLoadingText = NSLocalizedString("loading", comment: "")
    static let addButtonTitle = NSLocalizedString("Add New Dictionary", comment: "")
    static let deleteAllButtonTitle = NSLocalizedString("Delete All Dictionaries", comment: "")
}

private enum Sizings {
}

struct DictionariesView: View {

    @ObservedObject private var viewModel: DictionariesViewModel = DictionariesViewModel()
    
    var body: some View {
        
        Text(Strings.title)
            .font(.largeTitle)
            .foregroundColor(.black)
            .onAppear {
                viewModel.onViewAppear()
            }
    
        if viewModel.loading {
            CustomizableLoadingView(text: $viewModel.loadingText)
        
        } else {
            HStack {
                Spacer()
                
                Button(Strings.addButtonTitle,
                       action: {
                    viewModel.selectFolder()
                })
                .foregroundColor(.black)

                Button(Strings.deleteAllButtonTitle,
                       action: {
                    
                    viewModel.onDeleteAllButtonPressed()
                })
                .foregroundColor(.black)
            }
            
            List {
                ForEach(viewModel.items, id: \.name) { item in
                    
                    DictionaryRow(viewModel: DictionaryRowViewModel(model: item,
                                                                    onDelete: { name in
                        viewModel.onDeleteRowButtonPressed(name: name)
                    }))
                }
                .onMove(perform: viewModel.onMove)
                .background(Color.clear)
            }
            .background(Color.clear)
            .frame(minHeight: 300.0, maxHeight: .infinity)
            .onChange(of: viewModel.items) { newValue in
                viewModel.onUpdateOrderOfDictionaries()
            }
        
        }
    }
}

extension NSTableView {
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

    backgroundColor = NSColor.clear
        enclosingScrollView?.drawsBackground = false
    }
}
