import Foundation
import Realm
import RealmSwift
import TaihenDictionarySupport

protocol TagManagementDataController {
    func reloadTags()
}

public class RealmTag: Object {
    @Persisted(primaryKey: true) var _name: String
    @Persisted var color: Int
}

extension TaihenCustomDictionaryTag {
    
    static func from(entity: RealmTag) -> TaihenCustomDictionaryTag {
        
        let tag = TaihenCustomDictionaryTag(shortName: entity._name,
                                            extraInfo: "",
                                            color: Int(entity.color),
                                            tagDescription: "",
                                            piority: 0)
        
        return tag
    }
}

class RealmTagManagementDataController: TagManagementDataController {
    private var realm: Realm

    func getRealm() -> Realm {
        var config = Realm.Configuration()
        config.deleteRealmIfMigrationNeeded = true
        return try! Realm(configuration: config)
    }

    init(deleteOnLaunch: Bool = false) {
        
        var config = Realm.Configuration()
        config.deleteRealmIfMigrationNeeded = true
        realm = try! Realm(configuration: config)

        if deleteOnLaunch {
            realm.beginWrite()
            realm.deleteAll()
            
            do {
                try realm.commitWrite()

            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func reloadTags() {
        self.realm = getRealm()

        TagManager.setTags(
            realm.objects(RealmTag.self)
                .map({ TaihenCustomDictionaryTag.from(entity: $0) })
        )
    }
}
