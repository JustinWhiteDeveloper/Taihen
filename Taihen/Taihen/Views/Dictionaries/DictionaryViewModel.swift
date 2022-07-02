import Foundation

struct DictionaryViewModel: Equatable {
    var name: String
    var order: Int
    var active: Bool
}

extension DictionaryViewModel {
    var managedModel: ManagedDictionaryViewModel {
        return ManagedDictionaryViewModel(name: name, order: order, active: active)
    }
}
