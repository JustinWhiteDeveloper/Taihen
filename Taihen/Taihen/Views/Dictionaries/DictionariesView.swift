import Foundation
import SwiftUI
import TaihenDictionarySupport

private enum Strings {
    
    static let title = "Dictionaries"
    static let defaultLoadingText = "loading"
    static let readingFile = "Reading files from folder"
    static let savingDictionary = "Saving dictionary"
    static let deletingDictionary = "Deleting dictionary"
    static let deletingDictionaries = "Deleting dictionaries"
    static let addButtonTitle = "Add Dictionaries"
    static let deleteAllButtonTitle = "Delete All"
}

private enum Sizings {
    static let folderPickerSize = CGSize(width: 500.0, height: 600.0)
}

class DictionariesViewModel: ObservableObject {
    
    @Published var items: [DictionaryRowModel] = []
    @Published var loading: Bool = false
    @Published var loadingText: String = Strings.defaultLoadingText
        
    init() {}
    
    func onViewAppear() {
        items = SharedManagedDataController.dictionaryInstance.dictionaryViewModels()?
            .map({
                DictionaryRowModel(name: $0.name, order: $0.order, active: $0.active)
            }) ?? []
    }
    
    func addDictionaryFromPath(_ path: String) {
        
        loading = true
        loadingText = Strings.readingFile

        let reader: TaihenCustomDictionaryReader = ConcreteTaihenCustomDictionaryReader()
        
        DispatchQueue.global(qos: .background).async {
            guard let dictionary = reader.readFolder(path: path) else {
                self.loading = false
                return
            }
            
            self.loadingText = Strings.savingDictionary

            DispatchQueue.main.async {

                SharedManagedDataController.dictionaryInstance.saveDictionary(dictionary,
                                                                              notifyOnBlockSize: 100) {
                    self.onViewAppear()
                    self.loading = false
                }
            }
        }
    }
        
    func selectFolder() {
        
        let folderPicker = FolderPicker(windowSize: Sizings.folderPickerSize)
        
        folderPicker.begin { response in
            
            if response == .OK {
                let pickedFolders = folderPicker.urls
                
                if let folder = pickedFolders.first?.path {
                    self.addDictionaryFromPath(folder)
                }
            }
        }
    }
    
    func onDeleteAllButtonPressed() {
        loading = true
        loadingText = Strings.deletingDictionaries

        SharedManagedDataController.dictionaryInstance.deleteAllDictionaries {
            
            self.loading = false
            self.onViewAppear()
        }
    }
    
    func onDeleteRowButtonPressed(name: String) {
        loading = true
        
        loadingText = Strings.deletingDictionary
        
        SharedManagedDataController.dictionaryInstance.deleteDictionary(name: name) { elements in
            
            self.loading = false
            self.items = elements.map({
                DictionaryRowModel(name: $0.name, order: $0.order, active: $0.active)
            })
        }
    }
    
    func onMove(source: IndexSet, destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
    
    func onRecieveNotification(notification output: Notification) {
        switch output.name {
        case Notification.Name.onSaveDictionaryUpdate:
            
            if let dict = output.object as? [String: Int],
                let progress = dict["progress"],
                let maxProgress = dict["maxProgress"] {
                
                loadingText = Strings.savingDictionary + " " + String(progress) + "/" + String(maxProgress)

            }
        default:
            break
        }
    }
    
    func onUpdateOrderOfDictionaries() {
        SharedManagedDataController.dictionaryInstance.updateDictionaryOrder(viewModels: items.map({ $0.managedModel }))
    }
}

struct DictionariesView: View {

    @ObservedObject var viewModel: DictionariesViewModel
    
    let pub = NotificationCenter.default
        .publisher(for: Notification.Name.onSaveDictionaryUpdate)

    var body: some View {
        
        VStack(alignment: .center, spacing: 0, content: {
            Text(Strings.title)
                .font(.largeTitle)
                .foregroundColor(.black)
                
            if viewModel.loading {
                CustomizableLoadingView(text: $viewModel.loadingText)
                    .onChange(of: viewModel.loading) { newValue in
                    if newValue == true {
                        viewModel.loadingText = Strings.defaultLoadingText
                    }
                }.onReceive(pub) { (output) in
                    viewModel.onRecieveNotification(notification: output)
                }
                
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
                    ForEach(viewModel.items, id:\.name) { item in
                        
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

