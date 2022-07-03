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
    
    @objc func onRecieveNotification(notification output: Notification) {
        switch output.name {
        case Notification.Name.onReadFile:
            
            guard let lastActiveKey = UserDefaults.standard.lastOpenedFileKey else {
                return
            }
            
            let data = SharedManagedDataController.appManagementInstance.fileContentsByKey(key: lastActiveKey)
            
            text = data?.content ?? ""
        default:
            break
        }
    }
    
    func onAppear() {
        guard let lastActiveKey = UserDefaults.standard.lastOpenedFileKey else {
            return
        }
        
        let data = SharedManagedDataController.appManagementInstance.fileContentsByKey(key: lastActiveKey)
        
        let marks: [ManagedHighlight] = data?.highlights ?? []
        
        highlights = marks.map({ $0.range } )
        text = data?.content ?? ""
    }
}
