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

class RealmManagedDictionaryController: DictionaryDataController {
    
    private static var dictionaries: [String] = []
    private static var activeDictionaries: [String] = []
    private static var activeHashes: [String] = []

    private var realm: Realm
    
    var input: Void

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
    
    func reloadDictionaries() {
        self.realm = getRealm()

        let dictionaries = realm.objects(RealmDictionary.self)

        RealmManagedDictionaryController.dictionaries = dictionaries.sorted(by: {$0.order < $1.order }).map({ $0._name })
        RealmManagedDictionaryController.activeDictionaries = dictionaries.sorted(by: {$0.order < $1.order }).filter({ $0.isActive }).map({ $0._name })
        RealmManagedDictionaryController.activeHashes = dictionaries.sorted(by: {$0.order < $1.order }).filter({ $0.isActive }).map({ $0.hashKey })
    }
    
    func searchValue(value: String, callback: @escaping (Bool, Double, [[TaihenDictionaryViewModel]], Int) -> Void) {
                
        DispatchQueue.global(qos: .background).async {
            
            self.realm = self.getRealm()

            if value.isEmpty || !value.containsValidJapaneseCharacters {
                
                DispatchQueue.main.async {
                    callback(false, 0, [], 0)
                }
                
                return
            }
            
            var search = value

            let dictStrings = RealmManagedDictionaryController.dictionaries
            let activeDicts = RealmManagedDictionaryController.activeDictionaries
            let activeHashes = RealmManagedDictionaryController.activeHashes

            var selectedTerms: [[TaihenDictionaryViewModel]] = []
            let time = Date()

            var resultCount = 0
            
            var terms2: [TaihenCustomDictionaryTerm] = []

            for activeDict in activeHashes {
                guard let objects = self.realm.object(ofType: RealmTerm.self, forPrimaryKey: activeDict + search + "0") else {
                    continue
                }

                terms2.append(TaihenCustomDictionaryTerm.from(entity: objects))
                
                var object = self.realm.object(ofType: RealmTerm.self, forPrimaryKey: activeDict + search + String(terms2.count))
                
                if object != nil {
                    while object != nil {
                        terms2.append(TaihenCustomDictionaryTerm.from(entity: object!))
                        object = self.realm.object(ofType: RealmTerm.self, forPrimaryKey: activeDict + search + String(terms2.count))
                    }
                }
                
                resultCount += terms2.count
            }
            
            let dictionary = ConcreteTaihenCustomDictionary(name: "", revision: "", tags: [], terms: terms2)
            
            let termDict: [String: [TaihenDictionaryViewModel]] = dictionary.termDict

            var models: [TaihenDictionaryViewModel] = termDict[search] ?? []

            for (index, _) in models.enumerated() {
                
                models[index].terms = models[index].terms
                    .filter({ activeDicts.contains($0.dictionary ?? "")})
                    .sorted { termA, termB in
                    
                    let indexA = dictStrings.firstIndex(of: termA.dictionary ?? "") ?? 0
                    let indexB = dictStrings.firstIndex(of: termB.dictionary ?? "") ?? 0
                    
                    return indexA < indexB
                }
            }
            
            selectedTerms = [models]
            
            let lookupTime = abs(time.timeIntervalSinceNow)
            
            //retry if possible
            if resultCount == 0 && search.count > 1 {
                
                let kanaCorrector: JPConjugator
                
                switch FeatureManager.instance.parserMode {
                case .Rule:
                    kanaCorrector = RuleJPConjugator()
                default:
                    kanaCorrector = HardCodedJPConjugator()
                }
                
                // Check kana map
                if let kanaMap = self.realm.object(ofType: RealmKanaMap.self, forPrimaryKey: search) {
                    
                    //TODO: for every term
                    if let firstTerm = kanaMap.terms.first {
                        
                        self.searchValue(value: firstTerm) { finished, timeTaken, selectedTerms, resultCount in
                            callback(finished, timeTaken + lookupTime, selectedTerms, resultCount)
                        }
                        
                        return
                    }
                    
                } else if let correctedSearch = kanaCorrector.correctTerm(search) {

                    for searchItem in correctedSearch {
                        for activeDict in activeHashes {

                            if self.realm.object(ofType: RealmTerm.self, forPrimaryKey: activeDict + searchItem + "0") != nil {

                                self.searchValue(value: searchItem) { finished, timeTaken, selectedTerms, resultCount in
                                    callback(finished, timeTaken + lookupTime, selectedTerms, resultCount)
                                }
                                
                                return
                                
                            }
                        }
                    }
                }
                
                search.removeLast()
                
                self.searchValue(value: search) { finished, timeTaken, selectedTerms, resultCount in
                    callback(finished, timeTaken + lookupTime, selectedTerms, resultCount)
                }
                
            } else {
                
                DispatchQueue.main.async {
                    callback(true, lookupTime, selectedTerms, resultCount)
                }
            }
        }
    }

    func saveDictionary(_ dictionary: TaihenCustomDictionary, notifyOnBlockSize: Int, callback: @escaping () -> Void) {

        DispatchQueue.global(qos: .background).async {
            
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

            for (_, term) in dictionary.terms.enumerated() {
                
                // Add kana maps for kana lookups
                if !term.kana.isEmpty {
                    if kanaMap[term.kana] == nil {
                        kanaMap[term.kana] = []
                    }
                    
                    kanaMap[term.kana]?.append(term.term)
                }
            }
            
            let kanaMapsCount = kanaMap.keys.count

            
            for (index, term) in dictionary.terms.enumerated() {

                if index % notifyOnBlockSize == 0 {
                    DispatchQueue.main.async {
                        
                        var object: [String: Int] = [:]
                        
                        object["progress"] = index
                        object["maxProgress"] = maxTerms + kanaMapsCount
                        
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
                
                for item in value {
                    
                    if !realmKana.terms.contains(item) {
                        realmKana.terms.append(item)
                    }
                }
                
                self.realm.add(realmKana, update: .modified)
                
                index += 1
                
                if index % notifyOnBlockSize == 0 {
                    DispatchQueue.main.async {
                        
                        var object: [String: Int] = [:]
                        
                        object["progress"] = maxTerms + index
                        object["maxProgress"] = maxTerms + kanaMapsCount
                        
                        NotificationCenter.default.post(name: Notification.Name.onSaveDictionaryUpdate,
                                                        object: object)
                    }
                }
            }
            
            for tag in dictionary.tags {
                let realmTag = RealmTag()
                realmTag._name = tag.shortName
                realmTag.color = tag.color
                self.realm.add(realmTag, update: .modified)
            }

            try! self.realm.commitWrite()
            
            
            DispatchQueue.main.async {
                callback()
            }
        }
    }
    
    func dictionaryViewModels() -> [ManagedDictionaryViewModel]? {
        self.realm = getRealm()

        let dictionaries = realm.objects(RealmDictionary.self)

        return dictionaries.map({ ManagedDictionaryViewModel(name: $0._name, order: Int($0.order), active: $0.isActive)})
            .sorted(by: { $0.order < $1.order })
    }
    
    func updateDictionaryActive(viewModel model: ManagedDictionaryViewModel, active: Bool) {
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
        self.realm = getRealm()

        let dictionaries = realm.objects(RealmDictionary.self)
        
        realm.beginWrite()
        
        for dictionary in dictionaries {
            for (index, element) in items.enumerated() {
                
                if dictionary._name == element.name {
                    dictionary.order = index
                }
            }
        }
        
        do {
            try realm.commitWrite()

        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteDictionary(name: String, callback: @escaping ([ManagedDictionaryViewModel]) -> Void) {
        
        DispatchQueue.global(qos: .background).async { [self] in
            self.realm = self.getRealm()

            let dictionary = self.realm.object(ofType: RealmDictionary.self, forPrimaryKey: name)
            let terms = self.realm.objects(RealmTerm.self)

            self.realm.beginWrite()
                
            if let dictionary = dictionary {
                self.realm.delete(dictionary)
            }

            for item in terms {
                
                if item.dictionaryName == name {
                    self.realm.delete(item)
                }
            }
            
            do {
                try realm.commitWrite()

            } catch {
                print(error.localizedDescription)
            }
            
            DispatchQueue.main.async {
                callback(self.dictionaryViewModels() ?? [])
            }
        }
    }

    func termDescriptionToClipboard(term: String) {
        
        input = searchValue(value: term) { finished, _, model, _ in
            
            guard finished else {
                return
            }
            
            let yomiFormatter = YomiFormatter()
            
            let selectedModel = model.first ?? []
            
            if let firstModel = selectedModel.first {
                
                let copyText = yomiFormatter.formatForTerms(terms: firstModel)
                
                CopyboardEnabler.enabled = false
                
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString( copyText, forType: .string)
                
                print(copyText)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    CopyboardEnabler.enabled = true
                }
            }
        }
    }
    
    func deleteAllDictionaries(callback: @escaping () -> Void) {
        
        DispatchQueue.global(qos: .background).async { [self] in
            self.realm = self.getRealm()

            let dictionaries = self.realm.objects(RealmDictionary.self)
            let terms = self.realm.objects(RealmTerm.self)
            let tags = self.realm.objects(RealmTag.self)
            
            self.realm.beginWrite()
            
            for item in dictionaries {
                self.realm.delete(item)
            }
            
            for item in terms {
                self.realm.delete(item)
            }
            
            for item in tags {
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
