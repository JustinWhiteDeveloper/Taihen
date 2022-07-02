import Foundation

extension Notification.Name {
    static let onSelectionChange = Notification.Name("onSelectionChange")
    static let onReadFile = Notification.Name("onReadFile")
    static let onSaveDictionaryUpdate = Notification.Name("onDictionarySaveUpdate")
    static let onDeleteDictionaryUpdate = Notification.Name("onDictionaryDeleteUpdate")
}

extension Notification {
    static func dictionaryUpdateProgress(progress: Int, maxProgress: Int) -> [String: Int] {
        var object: [String: Int] = [:]
        
        object["progress"] = progress
        object["maxProgress"] = maxProgress
        
        return object
    }
}
