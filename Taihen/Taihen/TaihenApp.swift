import SwiftUI

private enum Strings {
    static let openFolderTitle = NSLocalizedString("Open", comment: "")
}

@main
struct TaihenApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1000,
                       minHeight: 600,
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
        
        let folderChooserPoint = CGPoint(x: 0, y: 0)
        let folderChooserSize = CGSize(width: 500, height: 600)
        let folderChooserRectangle = CGRect(origin: folderChooserPoint, size: folderChooserSize)
        let folderPicker = NSOpenPanel(contentRect: folderChooserRectangle, styleMask: .utilityWindow, backing: .buffered, defer: true)
        
        folderPicker.canChooseDirectories = false
        folderPicker.canChooseFiles = true
        folderPicker.allowsMultipleSelection = false
        folderPicker.canDownloadUbiquitousContents = false
        folderPicker.canResolveUbiquitousConflicts = false
        
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

