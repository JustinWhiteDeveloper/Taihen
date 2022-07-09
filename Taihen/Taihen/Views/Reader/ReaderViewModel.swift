import Foundation
import UserNotifications
import SwiftUI

class ReaderViewModel: ObservableObject {
    
    @Published var text = ""
    @Published var scrollPercentage: Float = 0.0

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(onRecieveNotification(notification:)),
                                               name: Notification.Name.onReadFile,
                                               object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onRecieveNotification(notification output: Notification) {
        switch output.name {
        case Notification.Name.onReadFile:
            
            updateFile()

        default:
            break
        }
    }
    
    func onAppear() {
        updateFile()
    }
    
    func updateFile() {
        guard let lastActiveKey = UserDefaults.standard.lastOpenedFileKey else {
            return
        }
        
        let data = SharedManagedDataController.appManagementInstance.fileContentsByKey(key: lastActiveKey)
                
        text = data?.content ?? ""
    }
}
