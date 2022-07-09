import Foundation
import Realm
import RealmSwift
import Foundation

struct ManagedRange: Codable {
    
    static var zero: ManagedRange {
        ManagedRange(start: 0, length: 0)
    }
    
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
    
    static func from(stringValue: String) -> ManagedRange? {
        
        let decoder = JSONDecoder()
        
        do {
            
            guard let data = stringValue.data(using: .utf8) else {
                return nil
            }
            
            let result = try decoder.decode(ManagedRange.self, from: data)
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
    var highlights: [ManagedRange]
    var lastSelectedRange: ManagedRange
}
