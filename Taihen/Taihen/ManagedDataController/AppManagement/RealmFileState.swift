import Foundation
import Realm
import RealmSwift
import Foundation

class RealmFileState: Object {
    
    //Path hash
    @Persisted(primaryKey: true) var _key: String
    @Persisted var content: String
    @Persisted var highlights: List<String>
}

extension RealmFileState {
    var managedObject: ManagedFileState {
        
        var managedHighlights: [ManagedHighlight] = []
        
        for highlight in highlights {
            if let castedObject = ManagedHighlight.from(stringValue: highlight) {
                managedHighlights.append(castedObject)
            }
        }
        
        return ManagedFileState(key: _key, content: content, highlights: managedHighlights)
    }
}

struct ManagedHighlight: Codable {
    var start: Int
    var length: Int
    
    func stringValue() -> String? {
        
        let encoder = JSONEncoder()
        
        do {
            let result = try encoder.encode(self)
            return String(data: result, encoding: .utf8)
            
        } catch {
            return nil
        }
    }
    
    static func from(stringValue: String) -> ManagedHighlight? {
        
        let decoder = JSONDecoder()
        
        do {
            
            guard let data = stringValue.data(using: .utf8) else {
                return nil
            }
            
            let result = try decoder.decode(ManagedHighlight.self, from: data)
            return result
        } catch {
            return nil
        }
    }
    
    var range: NSRange {
        return NSRange(location: start, length: length)
    }
}

struct ManagedFileState {
    var key: String
    var content: String
    var highlights: [ManagedHighlight]
}
