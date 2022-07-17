import Foundation
import SwiftUI
import TaihenDictionarySupport

private enum Strings {
    static let title = NSLocalizedString("Dictionaries", comment: "")
    static let defaultLoadingText = NSLocalizedString("loading", comment: "")
    static let addButtonTitle = NSLocalizedString("Add New Dictionary", comment: "")
    static let deleteAllButtonTitle = NSLocalizedString("Delete All Dictionaries", comment: "")
    
    static let noDictionariesTitle = NSLocalizedString("No dictionaries found", comment: "")
}

struct DictionariesView: View {

    @StateObject private var viewModel: DictionariesViewModel = DictionariesViewModel()
    
    var body: some View {
        
        VStack {
            
            Text(Strings.title)
                .font(.title)
                .foregroundColor(.black)
                .padding()

            if viewModel.loading {
                CustomizableLoadingView(text: $viewModel.loadingText)
            
            } else {
                HStack {
                    
                    Button(Strings.addButtonTitle,
                           action: {
                        viewModel.selectFolder()
                    })
                    .foregroundColor(.black)
                    .padding()
                    
                    Spacer()
                    
                    if $viewModel.items.count > 0 {
                        Button(Strings.deleteAllButtonTitle,
                               action: {
                            
                            viewModel.onDeleteAllButtonPressed()
                        })
                        .foregroundColor(.black)
                        .padding()

                    }
                }
                
                if $viewModel.items.count == 0 {
                    Text(Strings.noDictionariesTitle)
                        .font(.title2)
                        .foregroundColor(.black)
                } else {
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

                    .onChange(of: viewModel.items) { newValue in
                        viewModel.onUpdateOrderOfDictionaries()
                    }
                }
            }
            
            Spacer()

        }
        .frame(maxWidth: .infinity,
                maxHeight: .infinity,
               alignment: .topLeading)
        .onAppear {
            viewModel.onViewAppear()
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
