import Foundation
import TaihenDictionarySupport

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

// Use a seperate View model to avoid coupling
struct ManagedDictionaryViewModel: Equatable {
    var name: String
    var order: Int
    var active: Bool
}
