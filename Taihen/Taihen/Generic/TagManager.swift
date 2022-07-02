import Foundation
import SwiftUI
import TaihenDictionarySupport

protocol TagManager {
    
}

class YomiChanTagManager: TagManager {
    static var tags: [TaihenCustomDictionaryTag] = [] {
        didSet {
            for tag in tags {
                tagDict[tag.shortName] = tag
            }
        }
    }
    
    static var tagDict: [String: TaihenCustomDictionaryTag] = [:]
    
    static func colorOfTag(name: String) -> Color {
    
        if let item = tagDict[name] {
            
            switch(item.color * -1) {
            case 0:
                return Colors.lightGreyColor
            case 2:
                return Colors.cyanColor
            case 3:
                return Colors.darkGreyColor
            case 5:
                return Colors.lightOrangeColor
            case 10:
                return Colors.darkBlueColor
            default:
                return Colors.purpleColor
            }
        }
        
        return Colors.purpleColor
    }
}
