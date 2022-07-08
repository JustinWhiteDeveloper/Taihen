import Foundation
import Realm
import RealmSwift
import TaihenDictionarySupport
import JapaneseConjugation

class RealmDictionary: Object {
    @Persisted(primaryKey: true) var _name: String
    @Persisted var hashKey: String
    @Persisted var revision: String
    @Persisted var isActive: Bool
    @Persisted var order: Int
}

class RealmTerm: Object {
    @Persisted(primaryKey: true) var _key: String
    @Persisted var term: String
    @Persisted var kana: String
    @Persisted var dictionaryName: String
    @Persisted var groupTags: List<String>
    @Persisted var meaningTags: List<String>
    @Persisted var meanings: List<String>
}

class RealmKanaMap: Object {
    @Persisted(primaryKey: true) var _key: String
    @Persisted var terms: List<String>
}

class RealmManagedDictionaryController: DictionaryDataReaderWriterController {
    
    static var dictionaries: [String] = []
    static var activeDictionaries: [String] = []
    static var activeHashes: [String] = []
    var isSearching = false

    private var input: Void
        
    var realm: Realm

    func getRealm() -> Realm {
        var config = Realm.Configuration()
        config.deleteRealmIfMigrationNeeded = true
        
        /// swiftlint:disable:next force_try
        return try! Realm(configuration: config)
    }
    
    init(deleteOnLaunch: Bool = false) {
        
        var config = Realm.Configuration()
        config.deleteRealmIfMigrationNeeded = true
        
        /// swiftlint:disable:next force_try
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

    func saveDictionary(_ dictionary: TaihenCustomDictionary,
                        notifyOnBlockSize: Int,
                        callback: @escaping () -> Void) {

        print("save")
        
        DispatchQueue.global(qos: .background).sync {
            
            self.realm = self.getRealm()

            var counterDict: [String: Int] = [:]

            self.realm.beginWrite()
                
            let realmDict = RealmDictionary()
            realmDict._name = dictionary.name
            
            let hashKey = dictionary.name.md5
            
            realmDict.hashKey = hashKey
            realmDict.revision = dictionary.revision
            realmDict.order = 0
            realmDict.isActive = true
            
            self.realm.add(realmDict, update: .modified)
            
            let maxTerms = dictionary.terms.count
            
            var kanaMap: [String: [String]] = [:]

            for term in dictionary.terms where !term.kana.isEmpty {
                
                if kanaMap[term.kana] == nil {
                    kanaMap[term.kana] = []
                }
                
                kanaMap[term.kana]?.append(term.term)
            }
            
            let kanaMapsCount = kanaMap.keys.count

            for (index, term) in dictionary.terms.enumerated() {

                if index % notifyOnBlockSize == 0 {
                    DispatchQueue.main.async {
                        let object = Notification.dictionaryUpdateProgress(progress: index,
                                                                           maxProgress: maxTerms + kanaMapsCount)
                        
                        NotificationCenter.default.post(name: Notification.Name.onSaveDictionaryUpdate,
                                                        object: object)
                    }
                }
                
                let counter = counterDict[term.term] ?? 0
                counterDict[term.term] = counter + 1
                
                let key = hashKey + term.term + String(counter)
                
                let realmTerm = RealmTerm()
                realmTerm._key = key
                realmTerm.term = term.term
                realmTerm.kana = term.kana
                
                for tag in term.meaningTags {
                    realmTerm.meaningTags.append(tag)
                }
                                
                for tag in term.termTags {
                    realmTerm.groupTags.append(tag)
                }
                                
                for tag in term.meanings {
                    realmTerm.meanings.append(tag)
                }
                
                realmTerm.dictionaryName = dictionary.name
                
                self.realm.add(realmTerm, update: .modified)
            }

            var index = 0
            
            for (key, value) in kanaMap {
                
                let oldObject = self.realm.object(ofType: RealmKanaMap.self, forPrimaryKey: key)
                let realmKana = oldObject ?? RealmKanaMap()
                
                // Can't change primary key if the object already exists
                if oldObject == nil {
                    realmKana._key = key
                }
                
                for item in value where !realmKana.terms.contains(item) {
                    realmKana.terms.append(item)
                }
                
                self.realm.add(realmKana, update: .modified)
                
                index += 1
                
                if index % notifyOnBlockSize == 0 {
                    DispatchQueue.main.async {
                        
                        let object = Notification.dictionaryUpdateProgress(progress: maxTerms + index,
                                                                           maxProgress: maxTerms + kanaMapsCount)
                        NotificationCenter.default.post(name: Notification.Name.onSaveDictionaryUpdate,
                                                        object: object)
                    }
                }
            }
            
            do {
                try self.realm.commitWrite()

            } catch {
                print(error.localizedDescription)
            }
            
            DispatchQueue.main.async {
                callback()
            }
        }
    }
    
    func updateDictionaryActive(viewModel model: ManagedDictionaryViewModel, active: Bool) {
        
        print("update dicts")

        self.realm = getRealm()

        let dictionary = realm.object(ofType: RealmDictionary.self, forPrimaryKey: model.name)
        
        realm.beginWrite()
        dictionary?.isActive = active
        
        do {
            try realm.commitWrite()

        } catch {
            print(error.localizedDescription)
        }
    }

    func updateDictionaryOrder(viewModels items: [ManagedDictionaryViewModel]) {
        
        print("update dictionary order")

        self.realm = getRealm()

        let dictionaries = realm.objects(RealmDictionary.self)
        
        realm.beginWrite()
        
        for dictionary in dictionaries {
            for (index, element) in items.enumerated() where dictionary._name == element.name {
                dictionary.order = index
            }
        }
        
        do {
            try realm.commitWrite()

        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteDictionary(name: String, callback: @escaping ([ManagedDictionaryViewModel]) -> Void) {
        print("delete dictionary")

        DispatchQueue.global(qos: .background).sync { [self] in
            self.realm = self.getRealm()
            
            let dictionary = self.realm.object(ofType: RealmDictionary.self, forPrimaryKey: name)
            
            //Note: loads all terms in DB, costly!
            let terms = self.realm.objects(RealmTerm.self)

            self.realm.beginWrite()
                
            if let dictionary = dictionary {
                self.realm.delete(dictionary)
            }

            for item in terms where item.dictionaryName == name {
                self.realm.delete(item)
            }
            
            do {
                try realm.commitWrite()

            } catch {
                print(error.localizedDescription)
            }
            
            let dictionaries = realm.objects(RealmDictionary.self)

            let models = dictionaries.map({ ManagedDictionaryViewModel(name: $0._name,
                                                                 order: Int($0.order),
                                                                 active: $0.isActive)})
                    .sorted(by: { $0.order < $1.order })
            
            callback(models)
        }
    }

    func deleteAllDictionaries(callback: @escaping () -> Void) {
        print("delete all dictionaries")

        DispatchQueue.global(qos: .background).sync { [self] in
            self.realm = self.getRealm()

            let dictionaries = self.realm.objects(RealmDictionary.self)
            let terms = self.realm.objects(RealmTerm.self)
            
            self.realm.beginWrite()
            
            for item in dictionaries {
                self.realm.delete(item)
            }
            
            for item in terms {
                self.realm.delete(item)
            }
            
            do {
                try realm.commitWrite()

            } catch {
                print(error.localizedDescription)
            }
            
            DispatchQueue.main.async {
                callback()
            }
        }
    }
}

extension RealmManagedDictionaryController: DictionaryReloadController {
    
    func dictionaryViewModels() -> [ManagedDictionaryViewModel]? {
        
        print("dictionary view models")

        self.realm = getRealm()

        let dictionaries = realm.objects(RealmDictionary.self)

        return dictionaries.map({ ManagedDictionaryViewModel(name: $0._name,
                                                             order: Int($0.order),
                                                             active: $0.isActive)})
            .sorted(by: { $0.order < $1.order })
    }
    
    func reloadDictionaries() {
        
        print("reload dictionaries")

        self.realm = getRealm()

        let dictionaries = realm.objects(RealmDictionary.self)

        RealmManagedDictionaryController.dictionaries = dictionaries
            .sorted(by: {$0.order < $1.order })
            .map({ $0._name })
        
        RealmManagedDictionaryController.activeDictionaries = dictionaries
            .sorted(by: {$0.order < $1.order })
            .filter({ $0.isActive })
            .map({ $0._name })
        
        RealmManagedDictionaryController.activeHashes = dictionaries
            .sorted(by: {$0.order < $1.order })
            .filter({ $0.isActive })
            .map({ $0.hashKey })
    }
}

extension TaihenCustomDictionaryTerm {
    
    static func from(entity: RealmTerm) -> TaihenCustomDictionaryTerm {
        
        var meaningTags: [String] = Array(entity.meaningTags)
                
        meaningTags.append(entity.dictionaryName)
        
        let term = TaihenCustomDictionaryTerm(term: entity.term,
                                              kana: entity.kana,
                                              meaningTags: meaningTags,
                                              explicitType: "",
                                              meanings: Array(entity.meanings),
                                              extraMeanings: [],
                                              index: 0,
                                              termTags: Array(entity.groupTags),
                                              dictionary: entity.dictionaryName)
        return term
    }
}
