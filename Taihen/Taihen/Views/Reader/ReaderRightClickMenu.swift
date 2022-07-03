import Foundation
import SwiftUI

private enum Strings {
}

class ReaderRightClickMenu: NSMenu {
    
    init(target: AnyObject, highlightSelector: Selector?, unhighlightSelector: Selector?) {
        
        super.init(title: "Options")
        
        let highlightOption = NSMenuItem()
        highlightOption.title = "Highlight"
        highlightOption.target = target
        highlightOption.action = highlightSelector
        highlightOption.tag = 0
        
        addItem(highlightOption)
        
        let highlightOption2 = NSMenuItem()
        highlightOption2.title = "Remove Highlight"
        highlightOption2.target = target
        highlightOption2.action = unhighlightSelector
        highlightOption2.tag = 0
        
        addItem(highlightOption2)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
