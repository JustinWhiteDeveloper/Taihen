import TaihenDictionarySupport
import LaughingOctoAdventure
import Foundation

class TaihenSearchResult {
    private let models: [TaihenDictionaryViewModel]
    
    var searchModel: TaihenSearchViewModel? {
        
        let firstModel = models.first
        
        return firstModel.map { viewModel in
            
            TaihenSearchViewModel(groupTerm: viewModel.groupTerm,
                                  kana: viewModel.kana,
                                  terms: viewModel.terms.map({ item in
                
                TaihenSearchTerm(term: item.term,
                                 meaningTags: item.meaningTags,
                                 meanings: item.meanings)
                
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
    
    public var furiganaTerm: String {
        let groupTerm = groupTerm
        let kana = kana
        
        let furiganaFormatter = ConcreteFuriganaFormatter()
        return furiganaFormatter.formattedString(fromKanji: groupTerm, andHiragana: kana)
    }
    
    public var ankiExpression: String {

        let furiganaTerm = self.furiganaTerm
        
        //If contains hiragana and kanji then use *contains*
        let expressionPart = (furiganaTerm.containsKanji &&
                              furiganaTerm.containsHiragana) ? "*\(furiganaTerm)*" : furiganaTerm
        
        return "\"expression:\(expressionPart)\" OR \"Focus:\(groupTerm)\" OR \"Meaning:\(groupTerm)\" OR \"Front:\(expressionPart)\""
    }
    
    public var clipboardDescription: String {
        let meanings = terms.map({ $0.meanings })
            
        let clipboardFormatter = YomichanClipboardFormatter()
        return clipboardFormatter.formatForTerms(meanings)
    }
    
    public var audioUrl: URL? {
        let audioSource = LanguagePodAudioSource()
        return audioSource.url(forTerm: groupTerm,
                               andKana: kana)
    }
}

public struct TaihenSearchTerm: Equatable {
    public let term: String
    public let meaningTags: [String]
    public let meanings: [String]
    
    public var meaningDescription: String {
        let formatter = YomichanMeaningFormatter()
        return formatter.meaningDescription(meanings: meanings)
    }
    
    public var filteredMeaningTags: [String] {
        meaningTags.filter({ $0.count > 0 })
    }
}

protocol MeaningFormatter {
    func meaningDescription(meanings: [String]) -> String
}

class YomichanMeaningFormatter: MeaningFormatter {
    func meaningDescription(meanings: [String]) -> String {
        if meanings.count == 1 {
            return meanings.first ?? ""
            
        } else {
            
            var text = ""
            
            for (index, meaning) in meanings.enumerated() {
                text += "• " + meaning
                
                if index < meanings.count - 1 {
                    text += "\n"
                }
            }
            
            return text
        }
    }
}
