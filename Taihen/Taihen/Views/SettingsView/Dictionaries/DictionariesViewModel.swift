import Foundation
import TaihenDictionarySupport

private enum Strings {
    static let defaultLoadingText = NSLocalizedString("loading", comment: "")
    static let readingFile = NSLocalizedString("Reading files from folder", comment: "")
    static let savingTags = NSLocalizedString("Pre-processing tags", comment: "")
    static let savingDictionary = NSLocalizedString("Saving dictionary information", comment: "")
    static let deletingDictionary = NSLocalizedString("Deleting dictionary", comment: "")
    static let deletingDictionaries = NSLocalizedString("Deleting dictionaries", comment: "")
}

private enum Sizings {
    static let folderPickerSize = CGSize(width: 500.0, height: 600.0)
}

class DictionariesViewModel: ObservableObject {
    
    @Published var items: [DictionaryRowModel] = []
    @Published var loading: Bool = false {
        didSet {
            if loading {
                loadingText = Strings.defaultLoadingText
            }
        }
    }
    
    @Published var loadingText: String = Strings.defaultLoadingText
        
    init() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(onRecieveNotification(notification:)),
                                               name: Notification.Name.onSaveDictionaryUpdate,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onRecieveNotification(notification:)),
                                               name: Notification.Name.onDeleteDictionaryUpdate,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func onViewAppear() {
        items = SharedManagedDataController.dictionaryInstance.dictionaryViewModels()?
            .map({
                DictionaryRowModel(name: $0.name,
                                   order: $0.order,
                                   active: $0.active)
            }) ?? []
    }
    
    func addDictionaryFromPath(_ path: String) {
        
        loading = true
        loadingText = Strings.readingFile

        let reader: TaihenCustomDictionaryReader = ConcreteTaihenCustomDictionaryReader()
        
        DispatchQueue.global(qos: .background).async {
            guard let dictionary = reader.readFolder(path: path) else {
                DispatchQueue.main.async {
                    self.loading = false
                }
                return
            }

            DispatchQueue.main.async {
                self.loadingText = Strings.savingDictionary
            }
            
            SharedManagedDataController.tagManagementInstance.addTags(tags: dictionary.tags)
            
            SharedManagedDataController.dictionaryInstance.saveDictionary(dictionary,
                                                                          notifyOnBlockSize: 100) {
                self.onViewAppear()
                self.loading = false
                
                FeatureManager.instance.userHasFinishedIntro = true
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
        
        DispatchQueue.main.async {
            self.loadingText = Strings.deletingDictionary
        }
        
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
    
    @objc func onRecieveNotification(notification output: Notification) {
                
        switch output.name {
        case Notification.Name.onSaveDictionaryUpdate:
            
            if let dict = output.object as? [String: Int],
                let progress = dict["progress"],
                let maxProgress = dict["maxProgress"] {
                
                DispatchQueue.main.async {
                    self.loadingText = Strings.savingDictionary + " " + String(progress) + "/" + String(maxProgress)
                }
            }
        default:
            break
        }
    }
    
    func onUpdateOrderOfDictionaries() {
        SharedManagedDataController.dictionaryInstance.updateDictionaryOrder(viewModels: items.map({ $0.managedModel }))
    }
}
