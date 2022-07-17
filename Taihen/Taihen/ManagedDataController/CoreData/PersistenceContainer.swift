import CoreData

struct PersistenceController {
    
    private let modelName = "AppManagementModel"
    
    static let shared = PersistenceController()

    var container: NSPersistentContainer

    init(inMemory: Bool = false) {
        
        container = NSPersistentContainer(name: modelName)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Container Load Error: \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save Error" + error.localizedDescription)
            }
        }
    }
    
    mutating func deleteAll() {
        
        do {
            for store in container.persistentStoreCoordinator.persistentStores {
                try container.persistentStoreCoordinator.destroyPersistentStore(
                    at: store.url!,
                    ofType: store.type,
                    options: nil
                )
            }
            
            container = NSPersistentContainer(name: modelName)
            
            container.loadPersistentStores { description, error in
                if let error = error {
                    fatalError("Container Load Error: \(error.localizedDescription)")
                }
            }
        }
        catch {
            print(String(describing: error))
        }
        
    }
}
