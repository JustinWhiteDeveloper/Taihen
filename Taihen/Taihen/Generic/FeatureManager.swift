import Foundation
import SwiftUI

class FeatureManager {
    
    static let instance: FeatureManager = FeatureManager()
    
    private let userDefaults = UserDefaults.standard
    
    var audioEnabled: Bool {
        get {
            userDefaults.bool(forKey: "AudioEnabled")
        }
        
        set {
            userDefaults.set(newValue, forKey: "AudioEnabled")
        }
    }
    
    var autoplayAudio: Bool {
        get {
            userDefaults.bool(forKey: "AutoPlayAudio")
        }
        
        set {
            userDefaults.set(newValue, forKey: "AutoPlayAudio")
        }
    }
    
    var enableTextHighlights: Bool {
        get {
            userDefaults.bool(forKey: "EnableTextHighlights")
        }
        
        set {
            userDefaults.set(newValue, forKey: "EnableTextHighlights")
        }
    }
    
    var positionScrolling: Bool {
        get {
            userDefaults.bool(forKey: "PostionScrolling")
        }
        
        set {
            userDefaults.set(newValue, forKey: "PostionScrolling")
        }
    }
    
    var lookupPreviewEnabled: Bool {
        get {
            userDefaults.bool(forKey: "LookupPreviewEnabled")
        }
        
        set {
            userDefaults.set(newValue, forKey: "LookupPreviewEnabled")
        }
    }
    
    var clipboardReadingEnabled: Bool {
        get {
            (userDefaults.object(forKey: "ClipboardEnabled") as? Bool) ?? true
        }
        
        set {
            userDefaults.set(newValue, forKey: "ClipboardEnabled")
        }
    }
    
    var readerTextSize: Double {
        get {
            let value = userDefaults.double(forKey: "ReaderSize")
            
            if value == 0 {
                return 30.0
            } else {
                return value
            }
        }
        
        set {
            userDefaults.set(newValue, forKey: "ReaderSize")
        }
    }
    
    var dictionaryTextSize: Double {
        get {
            let value = userDefaults.double(forKey: "MiniReaderSize")
            
            if value == 0 {
                return 30.0
            } else {
                return value
            }
        }
        
        set {
            userDefaults.set(newValue, forKey: "MiniReaderSize")
        }
    }
    
    var readerBackgroundColor: Color {
        get {
            let valueR = userDefaults.double(forKey: "BGColorR")
            let valueG = userDefaults.double(forKey: "BGColorG")
            let valueB = userDefaults.double(forKey: "BGColorB")

            return Color(red: valueR, green: valueG, blue: valueB)
        }
        
        set {
            userDefaults.set(newValue.cgColor?.components?[0] ?? 0, forKey: "BGColorR")
            userDefaults.set(newValue.cgColor?.components?[1] ?? 0, forKey: "BGColorG")
            userDefaults.set(newValue.cgColor?.components?[2] ?? 0, forKey: "BGColorB")
        }
    }
    
    public enum TempJapaneseParserMode: Int {
        case Rule
        case Basic
        case AIBasic
    }
    
    var parserMode: TempJapaneseParserMode {
        get {
            let value = userDefaults.integer(forKey: "JPParserMode")
            
            return TempJapaneseParserMode(rawValue: value) ?? .Rule
        }
        
        set {
            userDefaults.set(newValue.rawValue, forKey: "JPParserMode")
        }
    }
    
    func setParserMode(value: Int) {
        parserMode = TempJapaneseParserMode(rawValue: value) ?? .Rule
    }
    
    func changeToNextParserMode() -> TempJapaneseParserMode {
        parserMode = TempJapaneseParserMode(rawValue: parserMode.rawValue + 1) ?? .Rule
        return parserMode
    }
}
