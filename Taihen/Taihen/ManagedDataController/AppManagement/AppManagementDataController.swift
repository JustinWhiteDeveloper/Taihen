import Foundation
import CoreData
import TaihenDictionarySupport

protocol AppManagementDataController {
    func saveFileContents(path: String, contents: String)
    func saveFileContents(path: String, highLights: [ManagedHighlight])
    func fileContentsByKey(key: String) -> ManagedFileState?
}
