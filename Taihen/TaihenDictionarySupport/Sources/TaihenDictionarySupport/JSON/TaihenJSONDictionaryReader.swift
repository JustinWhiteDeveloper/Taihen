import Foundation

protocol TaihenJSONDictionaryReader {
    func readFolder(_ folder: String) -> TaihenJSONDictionary?
    
    func readFolder(bundle: Bundle, subPath: String) -> TaihenJSONDictionary?
}

public class ConcreteTaihenJSONDictionaryReader: TaihenJSONDictionaryReader {
    
    private enum Constants {
        static let termFileDefensiveCodingLimit = 99
    }
    
    func readFolder(_ path: String) -> TaihenJSONDictionary? {
        let dictionary = ConcreteTaihenJSONDictionary()
        
        let indexPrefix: String = "index.json"
        let tagBankPrefix: String = "tag_bank_1.json"
        let termBankPrefix = "term_bank_"
        let termBankSuffix = ".json"
        
        // Read the index data
        guard let indexData = FileManager.default.contents(atPath: path + "/" + indexPrefix) else {
            return nil
        }
        
        do {
            let indexResult = try JSONDecoder().decode(TaihenJSONDictionaryIndex.self, from: indexData)
            dictionary.name = indexResult.title
            dictionary.format = indexResult.format
            dictionary.revision = indexResult.revision
            dictionary.sequenced = indexResult.sequenced
        } catch {
            return nil
        }
        
        // Read the tag data (Optional)
        if let tagData = FileManager.default.contents(atPath: path + "/" + tagBankPrefix) {
            do {
                let tagResult = try JSONDecoder().decode([TaihenJSONDictionaryTag].self, from: tagData)
                dictionary.tags = tagResult
            } catch {
                return nil
            }
        }
        
        var indexValue = 1
        
        //Loop until no files are found or meet the defensive coding limit
        while indexValue > 0, indexValue < Constants.termFileDefensiveCodingLimit {
            
            // Read the term data
            let indexPath = path + "/" + termBankPrefix + String(indexValue) + termBankSuffix
            
            guard let termData = FileManager.default.contents(atPath: indexPath) else {
                //No file found matching pattern
                break
            }
                
            do {
                let termResult = try JSONDecoder().decode([TaihenJSONDictionaryTerm].self, from: termData)
                dictionary.terms.append(contentsOf: termResult)
                
                indexValue += 1
            } catch {
                return nil
            }
        }
        
        return dictionary
    }
    
    func readFolder(bundle: Bundle, subPath: String) -> TaihenJSONDictionary? {
        let folder = bundle.bundlePath + "/Contents/Resources/" + subPath
        return readFolder(folder)
    }
}
