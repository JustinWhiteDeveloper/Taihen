import Foundation

class TaihenDictionaryBridge {
    
    func convertJsonToCustom(dictionary item: TaihenJSONDictionary) -> TaihenCustomDictionary? {
        
        let result = ConcreteTaihenCustomDictionary()
        
        result.name = item.name
        result.revision = item.revision
        result.tags = item.tags.map({ input in
            TaihenCustomDictionaryTag(shortName: input.shortName,
                                      extraInfo: input.extraInfo,
                                      color: input.color,
                                      tagDescription: input.tagDescription,
                                      piority: input.piority)
        })
        result.terms = item.terms.map({ input in
            TaihenCustomDictionaryTerm(term: input.term,
                                       kana: input.kana,
                                       meaningTags: input.meaningTags,
                                       explicitType: input.explicitType,
                                       meanings: input.meanings,
                                       extraMeanings: input.extraMeanings,
                                       index: input.index,
                                       termTags: input.termTags)
        })
        
        return result
    }
}
