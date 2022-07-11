import Foundation
import TaihenDictionarySupport

protocol DictionaryDataReaderWriterController {
    func saveDictionary(_ dictionary: TaihenCustomDictionary, notifyOnBlockSize: Int, callback: @escaping () -> Void)
    func updateDictionaryActive(viewModel model: ManagedDictionaryViewModel, active: Bool)
    func updateDictionaryOrder(viewModels items: [ManagedDictionaryViewModel])
    func deleteDictionary(name: String, callback: @escaping (_ elements: [ManagedDictionaryViewModel]) -> Void)
    func deleteAllDictionaries(callback: @escaping () -> Void)
}

protocol DictionaryReloadController {
    func dictionaryViewModels() -> [ManagedDictionaryViewModel]?
    func reloadDictionaries()
}

protocol DictionarySearchController {
    func searchValue(value: String,
                     timeAlreadyTaken: Double,
                     callback: @escaping (_ finished: Bool,
                                          _ timeTaken: Double,
                                          _ selectedTerms: TaihenSearchResult,
                                          _ resultCount: Int) -> Void
                     )
}

// Use a seperate View model to avoid coupling
struct ManagedDictionaryViewModel: Equatable {
    var name: String
    var order: Int
    var active: Bool
}
