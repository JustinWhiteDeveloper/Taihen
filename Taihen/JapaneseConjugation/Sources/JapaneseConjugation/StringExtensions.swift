import Foundation

internal extension String {
    func endsWithText(_ text: String) -> Bool {
        return self.range(of: "^.*\(text)$", options: String.CompareOptions.regularExpression) != nil
    }
}

