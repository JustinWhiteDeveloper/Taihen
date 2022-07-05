import Foundation
import UserNotifications
import SwiftUI

class ReaderViewModel: ObservableObject {
    
    @Published var text = ""
    @Published var highlights: [NSRange] = []
    @Published var scrollPercentage: Float = 0.0
    @Published var lookupPreviewEnabled = FeatureManager.instance.lookupPreviewEnabled

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
            
            update()

        default:
            break
        }
    }
    
    func onAppear() {
        update()
    }
    
    func update() {
        guard let lastActiveKey = UserDefaults.standard.lastOpenedFileKey else {
            return
        }
        
        let data = SharedManagedDataController.appManagementInstance.fileContentsByKey(key: lastActiveKey)
        
        let marks: [ManagedHighlight] = data?.highlights ?? []
        
        text = data?.content ?? ""
        highlights = marks.map({ $0.range })
    }
}
