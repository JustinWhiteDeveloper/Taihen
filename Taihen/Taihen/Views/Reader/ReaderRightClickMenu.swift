import Foundation
import SwiftUI

private enum Strings {
    static let title = NSLocalizedString("Options", comment: "")
    static let highlightOption = NSLocalizedString("Highlight", comment: "")
    static let unhighlightOption = NSLocalizedString("Remove Highlight", comment: "")
    static let copyOption = NSLocalizedString("Copy", comment: "")

}

class ReaderRightClickMenu: NSMenu {
    
    init(target: AnyObject, highlightSelector: Selector?, unhighlightSelector: Selector?, copySelector: Selector?) {
        
        super.init(title: Strings.title)
        
        let highlightOption = NSMenuItem()
        highlightOption.title = Strings.highlightOption
        highlightOption.target = target
        highlightOption.action = highlightSelector
        highlightOption.tag = 0
        
        addItem(highlightOption)
        
        let unhighlightOption = NSMenuItem()
        unhighlightOption.title = Strings.unhighlightOption
        unhighlightOption.target = target
        unhighlightOption.action = unhighlightSelector
        unhighlightOption.tag = 0
        
        addItem(unhighlightOption)
        
        let copyOption = NSMenuItem()
        copyOption.title = Strings.copyOption
        copyOption.target = target
        copyOption.action = copySelector
        copyOption.tag = 0
        
        addItem(copyOption)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
