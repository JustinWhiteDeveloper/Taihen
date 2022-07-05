import Foundation
import SwiftUI
import TaihenDictionarySupport

private enum Strings {
    static let title = NSLocalizedString("Dictionaries", comment: "")
    static let defaultLoadingText = NSLocalizedString("loading", comment: "")
    static let addButtonTitle = NSLocalizedString("Add Dictionaries", comment: "")
    static let deleteAllButtonTitle = NSLocalizedString("Delete All", comment: "")
}

private enum Sizings {
}

struct DictionariesView: View {

    @ObservedObject var viewModel: DictionariesViewModel = DictionariesViewModel()
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0, content: {
            Text(Strings.title)
                .font(.largeTitle)
                .foregroundColor(.black)
                
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
                        .padding()

                    }
                    .onMove(perform: viewModel.onMove)
                    .background(Color.clear)
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)
                .onChange(of: viewModel.items) { newValue in
                    viewModel.onUpdateOrderOfDictionaries()
                }
            
                Spacer()
            
            }
        })
        .frame(maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .center)
        .onAppear() {
            viewModel.onViewAppear()
        }
        .padding()
    }
}

extension NSTableView {
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

    backgroundColor = NSColor.clear
        enclosingScrollView?.drawsBackground = false
    }
}
