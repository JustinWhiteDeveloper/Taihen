import Foundation
import Realm
import RealmSwift
import TaihenDictionarySupport
import JapaneseConjugation

class CoreDataAppManagementDataController: AppManagementDataController {
    
    private var controller: PersistenceController

    init(controller: PersistenceController = PersistenceController.shared) {
        self.controller = controller
    }
    
    func saveFileContents(path: String, contents: String) {
                
        let fetchRequest: NSFetchRequest<ManagedFileEntity> = ManagedFileEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "key == %@", path.md5)

        if let object: ManagedFileEntity = (try? controller.container.viewContext.fetch(fetchRequest))?.first {
            object.content = contents
        } else {
            let newObject = ManagedFileEntity(context: controller.container.viewContext)
            newObject.key = path.md5
            newObject.content = contents
            newObject.highlights = []
            newObject.lastSelectedRange = ManagedRange.zero.stringValue()
        }
        
        controller.save()
    }
    
    func saveFileContents(path: String, highlights: [ManagedRange]) {
                
        let fetchRequest: NSFetchRequest<ManagedFileEntity> = ManagedFileEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "key == %@", path)
        
        if let object: ManagedFileEntity = (try? controller.container.viewContext.fetch(fetchRequest))?.first {
          
            object.highlights = highlights.map({ $0.stringValue() }).compactMap({ $0 })
            controller.save()
        }
    }
    
    func saveFileContents(path: String, lastSelectedRange: ManagedRange) {
                
        let fetchRequest: NSFetchRequest<ManagedFileEntity> = ManagedFileEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "key == %@", path)
        
        if let object: ManagedFileEntity = (try? controller.container.viewContext.fetch(fetchRequest))?.first {
          
            object.lastSelectedRange = lastSelectedRange.stringValue()
            controller.save()
        }
    }
    
    func fileContentsByKey(key: String) -> ManagedFileState? {
                
        let fetchRequest: NSFetchRequest<ManagedFileEntity> = ManagedFileEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "key == %@", key)
        
        guard let object: ManagedFileEntity = (try? controller.container.viewContext.fetch(fetchRequest))?.first else {
            return nil
        }
        
        guard let key = object.key,
                let content = object.content,
                let highlights = object.highlights,
                let lastSelectedRange = object.lastSelectedRange else {
            return nil
        }
        
        return ManagedFileState(key: key,
                                content: content,
                                highlights: highlights.map({ ManagedRange.from(stringValue: $0) }).compactMap({ $0 }),
                                lastSelectedRange:
                                    ManagedRange.from(stringValue: lastSelectedRange) ?? ManagedRange.zero)
    }
}

extension CoreDataAppManagementDataController: ManagedControllerResetSupport {
    func reset(callback: @escaping () -> Void) {
        controller.deleteAll()
        callback()
    }
}
