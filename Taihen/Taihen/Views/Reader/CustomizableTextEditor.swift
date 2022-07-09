import SwiftUI

struct CustomizableTextEditor: View {
    @Binding var text: String
    @Binding var scrollPercentage: Float
    
    @State var isLoading: Bool = true
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack {
                
                NSScrollableTextViewRepresentable(text: $text,
                                                  size: geometry.size,
                                                  scrollPercentage: $scrollPercentage,
                                                  isLoading: $isLoading)
                
                if isLoading {
                    CustomizableLoadingView(text: Binding.constant("Loading"))
                }
            }
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
    
    @Binding var text: String
    var size: CGSize
    @State var setText: Bool = false
    @Binding var scrollPercentage: Float
    @Binding var isLoading: Bool
        
    func makeNSView(context: Context) -> NSScrollView {
        
        let scrollView = NSTextView.scrollableTextView()
        
        guard let nsTextView = scrollView.documentView as? NSTextView else {
            return scrollView
        }
        
        nsTextView.textColor = .black
        nsTextView.insertionPointColor = NSColor.black
        nsTextView.textContainerInset = NSSize(width: Sizings.containerWidthInset,
                                               height: Sizings.containerHeightInset)
        nsTextView.font = NSFont.userFont(ofSize: FeatureManager.instance.readerTextSize)
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
        coordinator.textView = nsTextView

        if nsTextView.string != text {
            nsTextView.string = text
        }
    }

    // Create Coordinator for this View
    func makeCoordinator() -> TextCoordinator {
        TextCoordinator(textEditor: self)
    }
    
    func setLoaded() {
        isLoading = false
    }
}

// Using alternate naming as Coordinator still not mature..
private enum Dimensions {}

// Declare nested Coordinator class which conforms to NSTextViewDelegate
class TextCoordinator: NSObject, NSTextViewDelegate {
    
    typealias Representable = NSScrollableTextViewRepresentable
    
    var parent: Representable // store reference to parent
        
    var highlights: [NSRange] = []
    
    var lastSelectedRange: NSRange?
    var lastSelectedCharIndex: Int?

    var timer: Timer?
    var hasDonePostLayout = false
    
    weak var textView: NSTextView?

    init(textEditor: Representable) {
        self.parent = textEditor

        super.init()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onReadFile(_:)),
                                               name: Notification.Name.onReadFile,
                                               object: nil)

        layoutIfNeeded()
    }
    
    func textDidChange(_ notification: Notification) {
        guard notification.name == NSText.didChangeNotification,
            let nsTextView = notification.object as? NSTextView else {
            return
        }
        
        // set SwiftUI-Binding
        parent.text = nsTextView.string
    }
    
    private func setupHighlights() {
        
        if let lastActiveKey = UserDefaults.standard.lastOpenedFileKey {
            let data = SharedManagedDataController.appManagementInstance.fileContentsByKey(key: lastActiveKey)
            
            let managedHighlights: [ManagedRange] = data?.highlights ?? []
            highlights = managedHighlights.map({ $0.range })
        }
        
        let lastHighlightLocation = highlights.map({ $0.location}).sorted().last ?? 0
        
        if lastHighlightLocation <= parent.text.count {
            for range in highlights {
                let attrs: [NSAttributedString.Key: Any] = [NSAttributedString.Key.backgroundColor: Colors.highlight]
                textView?.textStorage?.addAttributes(attrs, range: range)
            }
        }
    }
    
    @objc func onReadFile(_ notification: Notification) {
        guard notification.name == Notification.Name.onReadFile else {
            return
        }
    
      //  setupHighlights()
    }
    
    func undoManager(for view: NSTextView) -> UndoManager? {
        nil
    }
    
    func textViewDidChangeSelection(_ notification: Notification) {
    
        guard let nsTextView = notification.object as? NSTextView, hasDonePostLayout else {
            return
        }
        
        DispatchQueue.main.async {
            self.parent.scrollPercentage = nsTextView.enclosingScrollView?.verticalScroller?.floatValue ?? 0
        }
        
        let text = nsTextView.selectedText

        lastSelectedRange = nsTextView.selectedRange()
        
        if text.count > 0 {
            NotificationCenter.default.post(name: Notification.Name.onSelectionChange, object: text)
            
        } else if let position = lastSelectedRange?.location {
            
            if let range = highlights.first(where: { $0.contains(position) }) {
                let text = nsTextView.string[range]
                
                NotificationCenter.default.post(name: Notification.Name.onSelectionChange,
                                                object: text)
            }
        }
        
        guard let lastActiveKey = UserDefaults.standard.lastOpenedFileKey,
              let lastSelectedRange = lastSelectedRange else {
            return
        }
        
        let range =  ManagedRange(start: lastSelectedRange.location,
                                  length: 0)
        
        SharedManagedDataController.appManagementInstance.saveFileContents(path: lastActiveKey,
                                                                           lastSelectedRange: range)
    }
    
    func textView(_ view: NSTextView, menu: NSMenu, for event: NSEvent, at charIndex: Int) -> NSMenu? {
        lastSelectedCharIndex = charIndex
        
        return ReaderRightClickMenu(target: self,
                                    highlightSelector: #selector(highlightItem),
                                    unhighlightSelector: #selector(unhighlightItem),
                                    copySelector: #selector(copyItem))
    }
    
    @objc func highlightItem() {
        
        if let range = lastSelectedRange {
            highlights.append(range)
            textView?.textStorage?.addAttributes([NSAttributedString.Key.backgroundColor: Colors.highlight],
                                                 range: range)
        }
        
        updateHighlightsOnDisk()
    }
    
    @objc func unhighlightItem() {
        
        for (index, item) in highlights.enumerated() {
            if let lastCharIndex = lastSelectedCharIndex,
                item.contains(lastCharIndex) {
                highlights.remove(at: index)
                textView?.textStorage?.removeAttribute(NSAttributedString.Key.backgroundColor, range: item)
            }
        }
    }
    
    @objc func copyItem() {
        
        guard let selectedText = textView?.selectedText else {
            return
        }
        
        CopyboardEnabler.enabled = false
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(selectedText, forType: .string)
                        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            CopyboardEnabler.enabled = true
        }
    }
    
    func updateHighlightsOnDisk() {
        
        guard let lastActiveKey = UserDefaults.standard.lastOpenedFileKey else {
            return
        }
        
        let mappedValues = highlights.map({ ManagedRange(start: $0.location, length: $0.length) })
        
        SharedManagedDataController.appManagementInstance.saveFileContents(path: lastActiveKey,
                                                                           highlights: mappedValues)
    }
    
    @objc func boundsChange(_ notification: Notification) {
        
        DispatchQueue.main.async {
            self.parent.scrollPercentage = self.textView?.enclosingScrollView?
                .verticalScroller?.floatValue ?? 0
        }
        
        layoutIfNeeded()
    }
    
    func layoutIfNeeded() {
        if !hasDonePostLayout {

            DispatchQueue.main.async {
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
                    print("layout")
                    self.hasDonePostLayout = true
                    
                    if let lastActiveKey = UserDefaults.standard.lastOpenedFileKey {
                        let appData = SharedManagedDataController.appManagementInstance
                            .fileContentsByKey(key: lastActiveKey)
                        
                        let lastRange = (appData?.lastSelectedRange ?? ManagedRange.zero).range
                        
                        self.textView?.scrollRangeToVisible(lastRange)
                        
                        self.setupHighlights()
                    }
                    
                    self.parent.setLoaded()
                })
            }
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
