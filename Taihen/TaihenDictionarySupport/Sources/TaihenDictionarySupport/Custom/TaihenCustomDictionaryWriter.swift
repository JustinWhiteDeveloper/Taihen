import Foundation

protocol TaihenCustomDictionaryWriter {
    func write(dictionary: ConcreteTaihenCustomDictionary, path: String)
}

class ConcreteTaihenCustomDictionaryWriter: TaihenCustomDictionaryWriter {
    func write(dictionary: ConcreteTaihenCustomDictionary, path: String) {
        
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(dictionary)
            try data.write(to: URL(fileURLWithPath: path))
            
        } catch {
            return
        }
    }
}
