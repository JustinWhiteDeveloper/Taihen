import Foundation

private enum Strings {
    static let fileKey = "lastActiveFileKey"
}

extension UserDefaults {
    var lastOpenedFileKey: String? {
        get {
            string(forKey: Strings.fileKey)
        }
        
        set {
            set(newValue, forKey: Strings.fileKey)
        }
    }
}
