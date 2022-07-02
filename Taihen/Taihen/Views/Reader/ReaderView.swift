import Foundation
import SwiftUI
import UserNotifications

private enum Sizings {
    static let dictionaryPreviewMaximumSize: CGFloat = 600.0
}

struct ReaderView: View {

    @State var text = ""
    @State var highlights: [NSRange] = []
    @State var scrollPercentage: Float = 0.0
    
    private let pub = NotificationCenter.default.publisher(for: Notification.Name.onReadFile)

    var body: some View {
        
        ZStack {
            
            HSplitView() {
                CustomizableTextEditor(text: $text, highlights: $highlights, scrollPercentage: $scrollPercentage)
                    .onReceive(pub) { (output) in
                        
                        guard let lastActiveKey = UserDefaults.standard.lastOpenedFileKey else {
                            return
                        }
                        
                        let data = SharedManagedDataController.appManagementInstance.fileContentsByKey(key: lastActiveKey)
                        
                        text = data?.content ?? ""
                    }
                if FeatureManager.instance.lookupPreviewEnabled {

                    YomiPreviewView(parentValue: Binding.constant(""))
                        .background(Colors.customGray1)
                        .padding()
                        .frame(maxWidth: Sizings.dictionaryPreviewMaximumSize)
                }
                
            }.onAppear {
                
                guard let lastActiveKey = UserDefaults.standard.lastOpenedFileKey else {
                    return
                }
                
                let data = SharedManagedDataController.appManagementInstance.fileContentsByKey(key: lastActiveKey)
                
                let marks: [ManagedHighlight] = data?.highlights ?? []
                
                highlights = marks.map({ $0.range } )
                text = data?.content ?? ""
            }
            
            HStack(alignment: .top) {
                Spacer()
                
                VStack(alignment: .trailing) {

                    Text(String(format: "%.2f", scrollPercentage * 100) + "%")
                        .foregroundColor(Color.black)
                    
                    Spacer()
                }
            }
        }
    }
}

struct CustomizableTextEditor: View {
    @Binding var text: String
    @Binding var highlights: [NSRange]
    @Binding var scrollPercentage: Float
    
    var body: some View {
        
        GeometryReader { geometry in
            NSScrollableTextViewRepresentable(text: $text, size: geometry.size, highlights: $highlights, scrollPercentage: $scrollPercentage)
        }
    }
}

struct NSScrollableTextViewRepresentable: NSViewRepresentable {
    typealias Representable = Self
    
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
        
        nsTextView.textContainerInset = NSSize(width: 20.0, height: 20.0)
        nsTextView.font = NSFont.userFont(ofSize: FeatureManager.instance.readerTextSize)
        
        // use SwiftUI Coordinator as the delegate
        nsTextView.delegate = context.coordinator
        
        // set drawsBackground to false (=> clear Background)
        // use .background-modifier later with SwiftUI-View
        nsTextView.drawsBackground = true
        nsTextView.backgroundColor = NSColor(FeatureManager.instance.readerBackgroundColor)
        
        // allow undo/redo
        nsTextView.allowsUndo = true
                
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        
        let coordinator = context.coordinator
        
        scrollPercentage = scrollView.verticalScroller?.floatValue ?? 0
        
        // get wrapped nsTextView
        guard let nsTextView = scrollView.documentView as? NSTextView else {
            return
        }
        
        scrollView.contentView.postsFrameChangedNotifications = true
                
        // fill entire given size
        nsTextView.minSize = size
        
        if nsTextView.string != text, !coordinator.isFirstTextLayout {
            nsTextView.string = text
            coordinator.isFirstTextLayout = false
        }
        
        if scrollView.contentView.visibleRect.size.height > 100, context.coordinator.firstBoundsChange {
            
            let fullRange = nsTextView.textStorage?.string.count ?? 0
            
            if fullRange > 2, FeatureManager.instance.positionScrolling {
                
                //Wait until layout has finished
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {

                    if let oldY = UserDefaults.standard.string(forKey: "ScrollPosY"),
                        let tRange = text.localizedStandardRange(of: oldY) {
                                                
                        let sRange: NSRange = NSRange(tRange, in: text)
                        
                        nsTextView.scrollRangeToVisible(sRange)
                    }
                }
            }
            
            context.coordinator.firstBoundsChange = false
        }
        
        if coordinator.highLightsNeedUpdate, FeatureManager.instance.enableTextHighlights {

            for range in highlights {

                let highlightColor = NSColor(deviceRed: 1, green: 1, blue: 0, alpha: 0.5)
                
                let attrs: [NSAttributedString.Key: Any] = [NSAttributedString.Key.backgroundColor: highlightColor]
                nsTextView.textStorage?.addAttributes(attrs, range: range)

            }
        }

        NotificationCenter.default.addObserver(context.coordinator,
                                               selector: #selector(context.coordinator.boundsChange),
                                               name: NSView.boundsDidChangeNotification,
                                               object: scrollView.contentView)
        
    }
    
    // Create Coordinator for this View
    func makeCoordinator() -> Coordinator {
        Coordinator(textEditor: self)
    }
    
    // Declare nested Coordinator class which conforms to NSTextViewDelegate
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: Representable // store reference to parent
        
        var firstBoundsChange = true
        
        var lastSelectedText: String?
        var lastSelectedRange: NSRange?
        var lastSelectedCharIndex: Int?

        var highLightsNeedUpdate: Bool = true

        var isFirstTextLayout = false

        init(textEditor: Representable) {
            self.parent = textEditor

            super.init()
        }
        
        // delegate method to retrieve changed text
        func textDidChange(_ notification: Notification) {
            // check that Notification.name is of expected notification
            // cast Notification.object as NSTextView

            guard notification.name == NSText.didChangeNotification,
                let nsTextView = notification.object as? NSTextView else {
                return
            }
            
            // set SwiftUI-Binding
            parent.text = nsTextView.string
        }
        
        // Pass SwiftUI UndoManager to NSTextView
        func undoManager(for view: NSTextView) -> UndoManager? {
            parent.undoManger
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            

            guard let nsTextView = notification.object as? NSTextView else {
                return
            }
                        
            parent.scrollPercentage = nsTextView.enclosingScrollView?.verticalScroller?.floatValue ?? 0

            let text = nsTextView.selectedText

            lastSelectedText = text
            lastSelectedRange = nsTextView.selectedRange()
            
            if text.count > 0 {
                NotificationCenter.default.post(name: Notification.Name.onSelectionChange, object: text)
            } else {
                
                if let position = lastSelectedRange?.location {
                    for highlight in parent.highlights {
                        if highlight.contains(position) {
                            
                            let text = nsTextView.string[highlight]
                            
                            NotificationCenter.default.post(name: Notification.Name.onSelectionChange, object: text)
                            
                            break
                            
                        }
                    }
                }
            }

            let y = lastSelectedRange?.location ?? 0
            
            let textViewText = nsTextView.string
            
            let textCount = textViewText.count
            
            let copyCount = 20
            
            if textCount > copyCount + 1 {
                
                // not at bottom of view
                if (y < textCount - copyCount) {
                    let sY = textViewText.dropFirst(y)
                    
                    let sY2 = sY.dropLast(sY.count - copyCount)
                    
                    UserDefaults.standard.set(String(sY2), forKey: "ScrollPosY")
                }
            }
        }
        
        func textView(_ view: NSTextView, menu: NSMenu, for event: NSEvent, at charIndex: Int) -> NSMenu? {
            
            let menu = NSMenu(title: "Options")
            
            let highlightOption = NSMenuItem()
            highlightOption.title = "Highlight"
            highlightOption.target = self
            highlightOption.action = #selector(highlightItem)
            highlightOption.tag = 0
            
            menu.addItem(highlightOption)
            
            let highlightOption2 = NSMenuItem()
            highlightOption2.title = "Remove Highlight"
            highlightOption2.target = self
            highlightOption2.action = #selector(unhighlightItem)
            highlightOption2.tag = 0
            
            menu.addItem(highlightOption2)
            
            lastSelectedCharIndex = charIndex
            
            return menu
        }
        
        @objc func highlightItem() {
            
            if let range = lastSelectedRange {
                parent.highlights.append(range)
            }
            
            highLightsNeedUpdate = true
            
            updateHighlightsOnDisk()
        }
        
        @objc func unhighlightItem() {
            
            for (index, item) in parent.highlights.enumerated() {
                if item.contains(lastSelectedCharIndex ?? 0) {
                    parent.highlights.remove(at: index)
                }
            }
                        
            highLightsNeedUpdate = true
            
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
