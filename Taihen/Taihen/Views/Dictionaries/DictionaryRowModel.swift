import Foundation

struct DictionaryRowModel: Equatable {
    var name: String
    var order: Int
    var active: Bool
}

extension DictionaryRowModel {
    var managedModel: ManagedDictionaryViewModel {
        return ManagedDictionaryViewModel(name: name, order: order, active: active)
    }
}
