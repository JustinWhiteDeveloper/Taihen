import Combine
import SwiftUI
import AppKit

extension Publisher {
    func void() -> Publishers.Map<Self, Void> {
        self.map { _ in Void() }
    }
}

public extension View {
    func onPasteboardChange(for pasteboard: NSPasteboard = .general,
                            do callback: @escaping PasteboardCallback) -> some View {
        PasteboardChangeListenerView(containing: self, for: pasteboard, do: callback)
    }
}

public typealias PasteboardCallback = () -> Void

struct PasteboardChangeListenerView<T>: View where T: View {
    private let containingView: T
    
    @StateObject private var store: PasteboardChangeStore
    
    init(containing view: T, for pasteboard: NSPasteboard, do callback: @escaping PasteboardCallback) {
        self.containingView = view
        
        let store = PasteboardChangeStore(for: pasteboard, callback: callback)
        _store = StateObject<PasteboardChangeStore>(wrappedValue: store)
    }
    
    var body: some View {
        containingView
    }
}

final class PasteboardChangeStore: ObservableObject {
    
    private var pasteboardChangedSubscription: AnyCancellable?
    
    private let callback: PasteboardCallback
    
    init(for pasteboard: NSPasteboard, callback: @escaping PasteboardCallback) {
        self.callback = callback
        self.pasteboardChangedSubscription = getPasteboardChangedPublisher(pasteboard: pasteboard)
            .sink { [weak self] _ in self?.callback() }
    }
    
    private func getPasteboardChangedPublisher(pasteboard: NSPasteboard) -> AnyPublisher<Void, Never> {
        Timer.publish(every: 1, on: .current, in: .common)
            .autoconnect()
            .map { _ in
                let count = pasteboard.changeCount
                return count
            }
            .merge(with: Just(pasteboard.changeCount))
            .removeDuplicates()
            .dropFirst()
            .void()
            .eraseToAnyPublisher()
    }
}

extension NSPasteboard {
    func clipboardContent() -> String? {
        return NSPasteboard.general.pasteboardItems?.first?.string(forType: .string)
    }
}

class CopyboardEnabler {
    static var enabled = true
}
