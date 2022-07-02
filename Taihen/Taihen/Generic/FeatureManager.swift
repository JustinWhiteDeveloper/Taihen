import Foundation
import SwiftUI

private enum Strings {
    static let audioEnabled = "AudioEnabled"
    static let audioPlayAudio = "AutoPlayAudio"
    static let enableTextHighlights = "EnableTextHighlights"
    static let enablePositionScrolling = "PostionScrolling"
    
    static let lookupPreviewEnabled = "LookupPreviewEnabled"
    static let clipboardEnabled = "ClipboardEnabled"
    
    static let readerTextSize = "ReaderSize"
    static let dictionaryTextSize = "MiniReaderSize"
    
    static let readerBackgroundColorR = "BGColorR"
    static let readerBackgroundColorG = "BGColorG"
    static let readerBackgroundColorB = "BGColorB"
    
    static let japaneseParserMode = "JPParserMode"
}

private enum Sizings {
    static let defaultTextSize = 30.0
}

class FeatureManager {
    
    static let instance: FeatureManager = FeatureManager()
    
    private let userDefaults = UserDefaults.standard
    
    var audioEnabled: Bool {
        get {
            userDefaults.bool(forKey: Strings.audioEnabled)
        }
        
        set {
            userDefaults.set(newValue, forKey: Strings.audioEnabled)
        }
    }
    
    var autoplayAudio: Bool {
        get {
            userDefaults.bool(forKey: Strings.audioPlayAudio)
        }
        
        set {
            userDefaults.set(newValue, forKey: Strings.audioPlayAudio)
        }
    }
    
    var enableTextHighlights: Bool {
        get {
            userDefaults.bool(forKey: Strings.enableTextHighlights)
        }
        
        set {
            userDefaults.set(newValue, forKey: Strings.enableTextHighlights)
        }
    }
    
    var positionScrolling: Bool {
        get {
            userDefaults.bool(forKey: Strings.enablePositionScrolling)
        }
        
        set {
            userDefaults.set(newValue, forKey: Strings.enablePositionScrolling)
        }
    }
    
    var lookupPreviewEnabled: Bool {
        get {
            userDefaults.bool(forKey: Strings.lookupPreviewEnabled)
        }
        
        set {
            userDefaults.set(newValue, forKey: Strings.lookupPreviewEnabled)
        }
    }
    
    var clipboardReadingEnabled: Bool {
        get {
            (userDefaults.object(forKey: Strings.clipboardEnabled) as? Bool) ?? true
        }
        
        set {
            userDefaults.set(newValue, forKey: Strings.clipboardEnabled)
        }
    }
    
    var readerTextSize: Double {
        get {
            let value = userDefaults.double(forKey: Strings.readerTextSize)
            
            if value == 0 {
                return Sizings.defaultTextSize
            } else {
                return value
            }
        }
        
        set {
            userDefaults.set(newValue, forKey: Strings.readerTextSize)
        }
    }
    
    var dictionaryTextSize: Double {
        get {
            let value = userDefaults.double(forKey: Strings.dictionaryTextSize)
            
            if value == 0 {
                return Sizings.defaultTextSize
            } else {
                return value
            }
        }
        
        set {
            userDefaults.set(newValue, forKey: Strings.dictionaryTextSize)
        }
    }
    
    var readerBackgroundColor: Color {
        get {
            let valueR = userDefaults.double(forKey: Strings.readerBackgroundColorR)
            let valueG = userDefaults.double(forKey: Strings.readerBackgroundColorG)
            let valueB = userDefaults.double(forKey: Strings.readerBackgroundColorB)

            return Color(red: valueR, green: valueG, blue: valueB)
        }
        
        set {
            userDefaults.set(newValue.cgColor?.components?[0] ?? 0, forKey: Strings.readerBackgroundColorR)
            userDefaults.set(newValue.cgColor?.components?[1] ?? 0, forKey: Strings.readerBackgroundColorG)
            userDefaults.set(newValue.cgColor?.components?[2] ?? 0, forKey: Strings.readerBackgroundColorB)
        }
    }
    
    public enum TempJapaneseParserMode: Int {
        case Rule
        case Basic
        case AIBasic
    }
    
    var parserMode: TempJapaneseParserMode {
        get {
            let value = userDefaults.integer(forKey: Strings.japaneseParserMode)
            
            return TempJapaneseParserMode(rawValue: value) ?? .Rule
        }
        
        set {
            userDefaults.set(newValue.rawValue, forKey: Strings.japaneseParserMode)
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
