import SwiftUI

struct DictionaryRowModel: Equatable {
    var name: String
    var order: Int
    var active: Bool
}

class DictionaryRowViewModel: ObservableObject {
    
    @Published var model: DictionaryRowModel
    var onDelete: (_ name: String) -> Void

    init(model: DictionaryRowModel, onDelete: @escaping (_ name: String) -> Void) {
        self.model = model
        self.onDelete = onDelete
    }
    
    func onDeleteRow() {
        self.onDelete(model.name)
    }
    
    func onChangeOfActiveState(newValue: Bool) {
        SharedManagedDataController.dictionaryInstance.updateDictionaryActive(viewModel: model.managedModel, active: newValue)
    }
}

extension DictionaryRowModel {
    var managedModel: ManagedDictionaryViewModel {
        return ManagedDictionaryViewModel(name: name, order: order, active: active)
    }
}
