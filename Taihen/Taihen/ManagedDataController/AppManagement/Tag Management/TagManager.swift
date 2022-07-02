import Foundation
import SwiftUI
import TaihenDictionarySupport

class TagManager {
    private static var _tagDictionary: [String: TaihenCustomDictionaryTag] = [:]
    
    static func tagColorInteger(_ key: String) -> Int? {
        return _tagDictionary[key]?.color
    }
    
    static func setTags(_ tags: [TaihenCustomDictionaryTag]) {
        for tag in tags {
            _tagDictionary[tag.shortName] = tag
        }
    }
}
