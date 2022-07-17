import Foundation
import TaihenDictionarySupport
import CoreData
import SwiftUI

class CoreDataTagManagementDataController: TagManagementDataController {
    
    private var tagDictionary: [String: TaihenCustomDictionaryTag] = [:]

    private var controller: PersistenceController
    
    init(controller: PersistenceController = PersistenceController.shared) {
        self.controller = controller
    }
    
    func reloadTags() {
        let fetchRequest: NSFetchRequest<ManagedTagEntity> = ManagedTagEntity.fetchRequest()
        
        let objects: [ManagedTagEntity] = (try? controller.container.viewContext.fetch(fetchRequest)) ?? []
        
        let tags = objects.map({
            TaihenCustomDictionaryTag(shortName: $0.name ?? "",
                                      extraInfo: "",
                                      color: Int($0.color),
                                      tagDescription: "",
                                      piority: 0)
                       
            }
        )
        
        for tag in tags {
            tagDictionary[tag.shortName] = tag
        }
    }
    
    func addTags(tags: [TaihenCustomDictionaryTag]) {
        
        let viewContext = controller.container.viewContext
        let fetchRequest = ManagedTagEntity.fetchRequest()

        let results: [ManagedTagEntity] = (try? controller.container.viewContext.fetch(fetchRequest)) ?? []

        for tag in tags {
            
            let tagEntity: ManagedTagEntity
            
            if let entity = results.filter({$0.name == tag.shortName}).first {
                tagEntity = entity
            } else {
                tagEntity = ManagedTagEntity(context: viewContext)
                tagEntity.name = tag.shortName
            }
            
            tagEntity.color = Int64(tag.color)
        }

        controller.save()
    }
    
    func tagColor(_ key: String, colorScheme: ColorScheme = YomichanColorScheme()) -> Color {
        let integerValue = tagDictionary[key]?.color
        return colorScheme.integerToColor(integerValue)
    }
}

extension CoreDataTagManagementDataController: ManagedControllerResetSupport {
    func reset(callback: @escaping () -> Void) {
        controller.deleteAll()
        callback()
    }
}
