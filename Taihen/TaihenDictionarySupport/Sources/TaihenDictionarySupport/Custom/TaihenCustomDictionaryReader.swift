import Foundation

public protocol TaihenCustomDictionaryReader {
    func readFile(path: String) -> ConcreteTaihenCustomDictionary?
    
    func readFolder(path: String) -> TaihenCustomDictionary?
}

public class ConcreteTaihenCustomDictionaryReader: TaihenCustomDictionaryReader {
    
    public init() {}
    
    public func readFile(path: String) -> ConcreteTaihenCustomDictionary? {

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let item = try JSONDecoder().decode(ConcreteTaihenCustomDictionary.self, from: data)
            return item
        }
        catch(let error) {
            print(String(describing: error))
            return nil
        }
    }
    
    public func readFolder(path: String) -> TaihenCustomDictionary? {

        let innerReader = ConcreteTaihenJSONDictionaryReader()
        
        guard let dictionary = innerReader.readFolder(path) else {
            return nil
        }
        
        guard let dictionary2 = TaihenDictionaryBridge()
            .convertJsonToCustom(dictionary: dictionary) else {
            return nil
        }
        
        return dictionary2
    }
}
