import TaihenDictionarySupport

class TaihenSearchResult {
    private let models: [TaihenDictionaryViewModel]
    
    var searchModel: TaihenSearchViewModel? {
        models.first.map { viewModel in
            
            TaihenSearchViewModel(groupTerm: viewModel.groupTerm,
                                  kana: viewModel.kana,
                                  terms: viewModel.terms.map({ item in
                
                TaihenSearchTerm(term: item.term,
                                 kana: item.kana,
                                 meaningTags: item.meaningTags,
                                 explicitType: item.explicitType,
                                 meanings: item.meanings,
                                 extraMeanings: item.extraMeanings,
                                 termTags: item.termTags)
                
            }),
                                  tags: viewModel.tags)
            
        }
    }
    
    init(models: [TaihenDictionaryViewModel]) {
        self.models = models
    }
}

public struct TaihenSearchViewModel: Equatable {
    public let groupTerm: String
    public let kana: String
    public var terms: [TaihenSearchTerm]
    public var tags: [String]
}

public struct TaihenSearchTerm: Equatable {
    public let term: String
    public let kana: String
    public let meaningTags: [String]
    public let explicitType: String
    public let meanings: [String]
    public let extraMeanings: [[String: String]]
    public let termTags: [String]
}
