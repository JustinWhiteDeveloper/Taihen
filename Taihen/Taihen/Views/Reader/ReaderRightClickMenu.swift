import Foundation
import SwiftUI

private enum Strings {
    static let title = NSLocalizedString("Options", comment: "")
    static let highlightOption = NSLocalizedString("Highlight", comment: "")
    static let unhighlightOption = NSLocalizedString("Remove Highlight", comment: "")
}

class ReaderRightClickMenu: NSMenu {
    
    init(target: AnyObject, highlightSelector: Selector?, unhighlightSelector: Selector?) {
        
        super.init(title: Strings.title)
        
        let highlightOption = NSMenuItem()
        highlightOption.title = Strings.highlightOption
        highlightOption.target = target
        highlightOption.action = highlightSelector
        highlightOption.tag = 0
        
        addItem(highlightOption)
        
        let highlightOption2 = NSMenuItem()
        highlightOption2.title = Strings.unhighlightOption
        highlightOption2.target = target
        highlightOption2.action = unhighlightSelector
        highlightOption2.tag = 0
        
        addItem(highlightOption2)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
