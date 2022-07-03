import SwiftUI

private enum Strings {
    static let openFolderTitle = NSLocalizedString("Open", comment: "")
}

private enum Sizings {
    static let minWindowSize = CGSize(width: 1000.0,
                                      height: 600.0)
    
    static let folderPickerSize = CGSize(width: 500.0,
                                         height: 600.0)
}

@main
struct TaihenApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(viewModel: MainViewModel(viewMode: .reader))
                .frame(minWidth: Sizings.minWindowSize.width,
                       minHeight: Sizings.minWindowSize.height,
                       alignment: .center)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button(action: {
                    selectFolder()
                }) {
                    Text(Strings.openFolderTitle)
                }
            }
            CommandGroup(replacing: .undoRedo) {}
            CommandGroup(replacing: .help) {}
        }
    }
    
    func selectFolder() {
        
        let folderPicker = FolderPicker(windowSize: Sizings.folderPickerSize,
                                        canChooseDirectories: false,
                                        allowMultipleSelection: false)
        
        folderPicker.begin { response in
            
            if response == .OK {
                let pickedFolders = folderPicker.urls
                
                if let folder = pickedFolders.first {
                    
                    let readText: String = try! String(contentsOf: folder)
                    
                    UserDefaults.standard.lastOpenedFileKey = folder.path.md5

                    SharedManagedDataController.appManagementInstance.saveFileContents(path: folder.path, contents: readText)
                    
                    NotificationCenter.default.post(name: Notification.Name.onReadFile, object: nil)
                    
                }
            }
        }
    }
}

