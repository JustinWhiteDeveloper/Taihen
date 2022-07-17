import Foundation
import CoreData
import TaihenDictionarySupport

protocol AppManagementDataController: ManagedControllerResetSupport {
    func saveFileContents(path: String, contents: String)
    func saveFileContents(path: String, highlights: [ManagedRange])
    func saveFileContents(path: String, lastSelectedRange: ManagedRange)
    func fileContentsByKey(key: String) -> ManagedFileState?
}
