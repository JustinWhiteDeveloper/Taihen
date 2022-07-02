import Foundation
import CoreData
import TaihenDictionarySupport

protocol ManagedDataController {
    func reloadTags()
    func saveFileContents(path: String, contents: String)
    func saveFileContents(path: String, highLights: [ManagedHighlight])
    func fileContentsByKey(key: String) -> ManagedFileState?
}

protocol DictionaryDataController {
    func reloadDictionaries()
    func termDescriptionToClipboard(term: String)
    func searchValue(value: String, callback: @escaping (_ finished: Bool, _ timeTaken: Double, _ selectedTerms: [[TaihenDictionaryViewModel]], _ resultCount: Int) -> Void)
    func saveDictionary(_ dictionary: TaihenCustomDictionary, notifyOnBlockSize: Int, callback: @escaping () -> Void)
    func dictionaryViewModels() -> [ManagedDictionaryViewModel]?
    func updateDictionaryActive(viewModel model: ManagedDictionaryViewModel, active: Bool)
    func updateDictionaryOrder(viewModels items: [ManagedDictionaryViewModel])
    func deleteDictionary(name: String, callback: @escaping (_ elements: [ManagedDictionaryViewModel]) -> Void) -> ()
    func deleteAllDictionaries(callback: @escaping () -> Void)
}

// Abstract away defining which implementation of the protocol is used
class SharedManagedDataController {
    static var instance: ManagedDataController = RealmManagedDataController()
    static var dictionaryInstance: DictionaryDataController = RealmManagedDictionaryController()
}

// Use a seperate View model to avoid coupling
struct ManagedDictionaryViewModel: Equatable {
    var name: String
    var order: Int
    var active: Bool
}
