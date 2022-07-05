import Foundation
import Realm
import RealmSwift
import TaihenDictionarySupport
import JapaneseConjugation

class RealmAppManagementDataController: AppManagementDataController {
    
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
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveFileContents(path: String, contents: String) {
        
        self.realm = getRealm()

        self.realm.beginWrite()

        let oldFileSaveObject = realm.object(ofType: RealmFileState.self, forPrimaryKey: path.md5)

        let fileContentObject = oldFileSaveObject ?? RealmFileState()
        
        if oldFileSaveObject == nil {
            fileContentObject._key = path.md5
        }
        
        fileContentObject.content = contents
        
        self.realm.add(fileContentObject, update: .modified)

        do {
            try self.realm.commitWrite()

        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveFileContents(path: String, highLights: [ManagedHighlight]) {
        self.realm = getRealm()

        self.realm.beginWrite()

        guard let object = realm.object(ofType: RealmFileState.self, forPrimaryKey: path) else {
            return
        }

        object.highlights = List<String>()

        let highLightList = highLights.map({ $0.stringValue()}).compactMap({ $0 })
        
        for item in highLightList {
            print(item.debugDescription)
            object.highlights.append(item)
        }

        self.realm.add(object, update: .modified)

        do {
            try self.realm.commitWrite()

        } catch {
            print(error.localizedDescription)
        }
    }

    func fileContentsByKey(key: String) -> ManagedFileState? {
        self.realm = getRealm()
        return realm.object(ofType: RealmFileState.self, forPrimaryKey: key)?.managedObject
    }
}
