import SwiftUI

struct CustomizableTextEditor: View {
    @Binding var text: String
    @Binding var highlights: [NSRange]
    @Binding var scrollPercentage: Float
    
    var body: some View {
        
        GeometryReader { geometry in
            NSScrollableTextViewRepresentable(text: $text,
                                              size: geometry.size,
                                              highlights: $highlights,
                                              scrollPercentage: $scrollPercentage)
        }
    }
}

private enum Sizings {
    static let containerWidthInset: CGFloat = 20.0
    static let containerHeightInset: CGFloat = 20.0
}

private extension Colors {
    static let highlight = NSColor(deviceRed: 1, green: 1, blue: 0, alpha: 0.5)
}

struct NSScrollableTextViewRepresentable: NSViewRepresentable {
    
    // Hook this binding up with the parent View
    @Binding var text: String
    
    var size: CGSize
    
    // Get the UndoManager
    @Environment(\.undoManager) var undoManger
            
    @Binding var highlights: [NSRange]
    
    @State var setText: Bool = false
    
    @Binding var scrollPercentage: Float

    // create an NSTextView
    func makeNSView(context: Context) -> NSScrollView {
        
        // create NSTextView inside NSScrollView
        let scrollView = NSTextView.scrollableTextView()
        
        let nsTextView = scrollView.documentView as! NSTextView
        nsTextView.textColor = .black
        nsTextView.insertionPointColor = NSColor.black
        
        nsTextView.textContainerInset = NSSize(width: Sizings.containerWidthInset,
                                               height: Sizings.containerHeightInset)
        nsTextView.font = NSFont.userFont(ofSize: FeatureManager.instance.readerTextSize)
        
        // use SwiftUI Coordinator as the delegate
        nsTextView.delegate = context.coordinator
        
        // set drawsBackground to false (=> clear Background)
        // use .background-modifier later with SwiftUI-View
        nsTextView.drawsBackground = true
        nsTextView.backgroundColor = NSColor(FeatureManager.instance.readerBackgroundColor)
        
        // allow undo/redo
        nsTextView.allowsUndo = true
                
        
        NotificationCenter.default.addObserver(context.coordinator,
                                               selector: #selector(context.coordinator.boundsChange),
                                               name: NSView.boundsDidChangeNotification,
                                               object: scrollView.contentView)
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        
        // get wrapped nsTextView
        guard let nsTextView = scrollView.documentView as? NSTextView else {
            return
        }
        
        scrollView.contentView.postsFrameChangedNotifications = true
        
        nsTextView.minSize = size
        
        let coordinator = context.coordinator
        
        if nsTextView.string != text || coordinator.isFirstTextLayout {
            nsTextView.string = text
            coordinator.isFirstTextLayout = false
        }

        if FeatureManager.instance.enableTextHighlights {

            for range in highlights {
                let attrs: [NSAttributedString.Key: Any] = [NSAttributedString.Key.backgroundColor: Colors.highlight]
                nsTextView.textStorage?.addAttributes(attrs, range: range)
            }
        }
        
        DispatchQueue.main.async {
            scrollPercentage = scrollView.verticalScroller?.floatValue ?? 0
        }
    }
    
    // Create Coordinator for this View
    func makeCoordinator() -> Coordinator {
        Coordinator(textEditor: self)
    }
}

// Using alternate naming as Coordinator still not mature..
private enum Dimensions {

    
}

// Declare nested Coordinator class which conforms to NSTextViewDelegate
class Coordinator: NSObject, NSTextViewDelegate {
    
    typealias Representable = NSScrollableTextViewRepresentable
    
    var parent: Representable // store reference to parent
        
    var lastSelectedRange: NSRange?
    var lastSelectedCharIndex: Int?

    // Don't relayout text as it overrides Attributed text
    var isFirstTextLayout: Bool = true
    
    init(textEditor: Representable) {
        self.parent = textEditor

        super.init()
    }
    
    func textDidChange(_ notification: Notification) {
        guard notification.name == NSText.didChangeNotification,
            let nsTextView = notification.object as? NSTextView else {
            return
        }
        
        // set SwiftUI-Binding
        parent.text = nsTextView.string
    }
    
    func undoManager(for view: NSTextView) -> UndoManager? {
        parent.undoManger
    }
    
    func textViewDidChangeSelection(_ notification: Notification) {
    
        guard let nsTextView = notification.object as? NSTextView else {
            return
        }
        
        DispatchQueue.main.async {
            self.parent.scrollPercentage = nsTextView.enclosingScrollView?.verticalScroller?.floatValue ?? 0
        }

        let text = nsTextView.selectedText

        lastSelectedRange = nsTextView.selectedRange()
        
        if text.count > 0 {
            NotificationCenter.default.post(name: Notification.Name.onSelectionChange, object: text)
        }
        else if let position = lastSelectedRange?.location {
            for highlight in parent.highlights {
                if highlight.contains(position) {
                    
                    let text = nsTextView.string[highlight]
                    
                    NotificationCenter.default.post(name: Notification.Name.onSelectionChange, object: text)
                    
                    break
                }
            }
        }
    }
    
    func textView(_ view: NSTextView, menu: NSMenu, for event: NSEvent, at charIndex: Int) -> NSMenu? {
        lastSelectedCharIndex = charIndex
        
        return ReaderRightClickMenu(target: self,
                                    highlightSelector: #selector(highlightItem),
                                    unhighlightSelector: #selector(unhighlightItem))
    }
    
    @objc func highlightItem() {
        
        if let range = lastSelectedRange {
            parent.highlights.append(range)
        }
                
        updateHighlightsOnDisk()
    }
    
    @objc func unhighlightItem() {
        
        for (index, item) in parent.highlights.enumerated() {
            if item.contains(lastSelectedCharIndex ?? 0) {
                parent.highlights.remove(at: index)
            }
        }
        
        isFirstTextLayout = true
                            
        updateHighlightsOnDisk()
    }
    
    func updateHighlightsOnDisk() {
        let mappedValues = parent.highlights.map({ ManagedHighlight(start: $0.location, length: $0.length) })
        
        guard let lastActiveKey = UserDefaults.standard.lastOpenedFileKey else {
            return
        }
        
        SharedManagedDataController.appManagementInstance.saveFileContents(path: lastActiveKey, highLights: mappedValues)
    }
    
    @objc func boundsChange(_ notification: Notification) {
        
        guard let nsScrollview = (notification.object as? NSClipView)?.enclosingScrollView else {
            return
        }
        
        parent.scrollPercentage = nsScrollview.verticalScroller?.floatValue ?? 0
    }
}

extension NSTextView {
  var selectedText: String {
      var text = ""
      for case let range as NSRange in self.selectedRanges {
          text.append(string[range] + "\n")
      }
      text = String(text.dropLast())
      return text
  }
}