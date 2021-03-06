import Foundation
import Realm
import RealmSwift
import TaihenDictionarySupport
import JapaneseConjugation

extension RealmManagedDictionaryController: DictionarySearchController {
    
    func searchValue(value: String,
                     timeAlreadyTaken: Double = 0,
                     callback: @escaping (Bool, Double, TaihenSearchResult, Int) -> Void) {
                
        print("search")

        // Use a sync queue to prevent Realm crashes from threading
        DispatchQueue.global(qos: .background).sync {
            
            self.realm = self.getRealm()

            if value.isEmpty || !value.containsValidJapaneseCharacters {
                
                DispatchQueue.main.async {
                    callback(false, 0, TaihenSearchResult(models: []), 0)
                }
                
                return
            }
            
            var search = value

            let dictStrings = RealmManagedDictionaryController.dictionaries
            let activeDicts = RealmManagedDictionaryController.activeDictionaries
            let activeHashes = RealmManagedDictionaryController.activeHashes

            let time = Date()

            var resultCount = 0
            
            var resultsFoundInDictionaries: [TaihenCustomDictionaryTerm] = []

            for activeDict in activeHashes {
                guard let objects = self.realm.object(ofType: RealmTerm.self,
                                                      forPrimaryKey: activeDict + search + "0") else {
                    continue
                }

                resultsFoundInDictionaries.append(TaihenCustomDictionaryTerm.from(entity: objects))
                
                let primaryKey = activeDict + search + String(resultsFoundInDictionaries.count)
                
                var object = self.realm.object(ofType: RealmTerm.self,
                                               forPrimaryKey: primaryKey)
                
                if object != nil {
                    while object != nil {
                        resultsFoundInDictionaries.append(TaihenCustomDictionaryTerm.from(entity: object!))
                        
                        let primaryKey = activeDict + search + String(resultsFoundInDictionaries.count)
                        
                        object = self.realm.object(ofType: RealmTerm.self,
                                                   forPrimaryKey: primaryKey)
                    }
                }
                
                resultCount += resultsFoundInDictionaries.count
            }
            
            let dictionary = ConcreteTaihenCustomDictionary(name: "",
                                                            revision: "",
                                                            tags: [],
                                                            terms: resultsFoundInDictionaries)
            
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
            
            let lookupTime = abs(time.timeIntervalSinceNow) + timeAlreadyTaken
            
            //retry if possible
            if resultCount == 0 && search.count > 1 {
                
                let kanaCorrector: JapaneseConjugator
                
                switch FeatureManager.instance.textSelectionParserMode {
                case .Rule:
                    kanaCorrector = RuleCollectionJapaneseConjugator()
                default:
                    kanaCorrector = RuleListJapaneseConjugator()
                }
                
                // Check kana map
                if let kanaMap = self.realm.object(ofType: RealmKanaMap.self,
                                                   forPrimaryKey: search) {
                    
                    // Note: Should be for every term
                    if let firstTerm = kanaMap.terms.first {
                        
                        self.searchValue(value: firstTerm,
                                         timeAlreadyTaken: lookupTime) { finished,
                            timeTaken,
                            selectedTerms,
                            resultCount in
                            
                            callback(finished, timeTaken, selectedTerms, resultCount)
                        }
                        
                        return
                    }
                    
                } else if let correctedSearch = kanaCorrector.correctTerm(search) {

                    for searchItem in correctedSearch {
                        for activeDict in activeHashes {

                            if self.realm.object(ofType: RealmTerm.self,
                                                 forPrimaryKey: activeDict + searchItem + "0") != nil {

                                self.searchValue(value: searchItem,
                                                 timeAlreadyTaken: lookupTime) { finished,
                                    timeTaken,
                                    selectedTerms,
                                    resultCount in
                                    
                                    callback(finished, timeTaken, selectedTerms, resultCount)
                                }
                                
                                return
                            }
                        }
                    }
                }
                
                search.removeLast()
                
                self.searchValue(value: search,
                                 timeAlreadyTaken: lookupTime) { finished,
                    timeTaken,
                    selectedTerms,
                    resultCount in
                    
                    callback(finished, timeTaken, selectedTerms, resultCount)
                }
                
            } else {
                
                DispatchQueue.main.async {
                    self.isSearching = false
                    
                    callback(true,
                             lookupTime,
                             TaihenSearchResult(models: models),
                             resultCount)
                }
            }
        }
    }
}
