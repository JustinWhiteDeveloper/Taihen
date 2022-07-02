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

private enum Sizings {}

struct DictionariesView: View {

    @State var items: [DictionaryViewModel] = []
    @State var loading: Bool = false
    @State var loadingText: String = Strings.defaultLoadingText
    
    let pub = NotificationCenter.default
        .publisher(for: Notification.Name.onSaveDictionaryUpdate)

    var body: some View {
        
        VStack(alignment: .center, spacing: 0, content: {
            Text(Strings.title)
                .font(.largeTitle)
                .foregroundColor(.black)
                
            if loading {
                CustomizableLoadingView(text: $loadingText)
                    .onChange(of: loading) { newValue in
                    if newValue == true {
                        loadingText = Strings.defaultLoadingText
                    }
                }.onReceive(pub) { (output) in
                    
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
                
            } else {
            
                HStack {
                    Spacer()
                    
                    Button(Strings.addButtonTitle,
                           action: {
                        selectFolder()
                    })
                    .foregroundColor(.black)

                    Button(Strings.deleteAllButtonTitle,
                           action: {
                        
                        loading = true
                        loadingText = Strings.deletingDictionaries

                        SharedManagedDataController.dictionaryInstance.deleteAllDictionaries {
                            
                            loading = false
                            onViewAppear()
                        }
                    })
                    .foregroundColor(.black)
                }
                
                List {
                    ForEach(items, id:\.name) { item in
                        
                        DictionaryRow(model: item, onDelete: { name in
                            
                            loading = true
                            
                            loadingText = Strings.deletingDictionary
                            
                            SharedManagedDataController.dictionaryInstance.deleteDictionary(name: name) { elements in
                                
                                loading = false
                                items = elements.map({
                                    DictionaryViewModel(name: $0.name, order: $0.order, active: $0.active)
                                })
                            }
                        })
                        .padding()

                    }
                    .onMove(perform: onMove)
                    .background(Color.clear)
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)
                .onChange(of: items) { newValue in
                    SharedManagedDataController.dictionaryInstance.updateDictionaryOrder(viewModels: items.map({ $0.managedModel }))
                }
            
                Spacer()
            
            }
        })
        .frame(maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .center)
        .onAppear() {
            onViewAppear()
        }
        .padding()

    }
    
    private func onMove(source: IndexSet, destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
    
    func onViewAppear() {
        items = SharedManagedDataController.dictionaryInstance.dictionaryViewModels()?
            .map({
                DictionaryViewModel(name: $0.name, order: $0.order, active: $0.active)
            }) ?? []
    }

    func addDictionaryFromPath(_ path: String) {
        
        loading = true
        loadingText = Strings.readingFile

        let reader: TaihenCustomDictionaryReader = ConcreteTaihenCustomDictionaryReader()
        
        DispatchQueue.global(qos: .background).async {
            guard let dictionary = reader.readFolder(path: path) else {
                loading = false
                return
            }
            
            loadingText = Strings.savingDictionary

            DispatchQueue.main.async {

                SharedManagedDataController.dictionaryInstance.saveDictionary(dictionary,
                                                                              notifyOnBlockSize: 100) {
                    onViewAppear()
                    loading = false
                }
            }
        }
    }
        
    func selectFolder() {
        
        let folderChooserPoint = CGPoint(x: 0, y: 0)
        let folderChooserSize = CGSize(width: 500, height: 600)
        let folderChooserRectangle = CGRect(origin: folderChooserPoint, size: folderChooserSize)
        let folderPicker = NSOpenPanel(contentRect: folderChooserRectangle, styleMask: .utilityWindow, backing: .buffered, defer: true)
        
        folderPicker.canChooseDirectories = true
        folderPicker.canChooseFiles = true
        folderPicker.allowsMultipleSelection = true
        folderPicker.canDownloadUbiquitousContents = true
        folderPicker.canResolveUbiquitousConflicts = true
        
        folderPicker.begin { response in
            
            if response == .OK {
                let pickedFolders = folderPicker.urls
                
                if let folder = pickedFolders.first?.path {
                    addDictionaryFromPath(folder)
                }
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

