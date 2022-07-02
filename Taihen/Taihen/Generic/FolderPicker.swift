import SwiftUI

class FolderPicker: NSOpenPanel {
    
    init(windowSize: CGSize,
         canChooseDirectories: Bool = true,
         allowMultipleSelection: Bool = true) {
        
        let folderChooserPoint = CGPoint.zero
        let folderChooserRectangle = CGRect(origin: folderChooserPoint,
                                            size: windowSize)
        
        super.init(contentRect: folderChooserRectangle,
                   styleMask: .utilityWindow,
                   backing: .buffered,
                   defer: true)
        
        self.canChooseDirectories = canChooseDirectories
        self.canChooseFiles = true
        self.allowsMultipleSelection = allowMultipleSelection
        self.canDownloadUbiquitousContents = false
        self.canResolveUbiquitousConflicts = false
    }
}
