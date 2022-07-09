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
    
    var autoplayAudio: Bool {
        get {
            userDefaults.bool(forKey: Strings.audioPlayAudio,
                              withDefaultValue: true)
        }
        
        set {
            userDefaults.set(newValue, forKey: Strings.audioPlayAudio)
        }
    }
    
    var enableTextHighlights: Bool {
        get {
            userDefaults.bool(forKey: Strings.enableTextHighlights,
                              withDefaultValue: true)
        }
        
        set {
            userDefaults.set(newValue, forKey: Strings.enableTextHighlights)
        }
    }
    
    var positionScrolling: Bool {
        get {
            userDefaults.bool(forKey: Strings.enablePositionScrolling,
                              withDefaultValue: false)
        }
        
        set {
            userDefaults.set(newValue, forKey: Strings.enablePositionScrolling)
        }
    }
    
    var lookupPreviewEnabled: Bool {
        get {
            userDefaults.bool(forKey: Strings.lookupPreviewEnabled,
                              withDefaultValue: true)
        }
        
        set {
            userDefaults.set(newValue, forKey: Strings.lookupPreviewEnabled)
        }
    }
    
    var clipboardReadingEnabled: Bool {
        get {
            userDefaults.bool(forKey: Strings.clipboardEnabled,
                              withDefaultValue: true)
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
            
            let defaultComponents = Colors.customGray2.cgColor?.components ?? [0.3, 0.3, 0.3]
            
            let valueR = userDefaults.double(forKey: Strings.readerBackgroundColorR,
                                             withDefaultValue: defaultComponents[0])
            let valueG = userDefaults.double(forKey: Strings.readerBackgroundColorG,
                                             withDefaultValue: defaultComponents[1])
            let valueB = userDefaults.double(forKey: Strings.readerBackgroundColorB,
                                             withDefaultValue: defaultComponents[2])

            return Color(red: valueR, green: valueG, blue: valueB)
        }
        
        set {
            userDefaults.set(newValue.cgColor?.components?[0] ?? 0.3, forKey: Strings.readerBackgroundColorR)
            userDefaults.set(newValue.cgColor?.components?[1] ?? 0.3, forKey: Strings.readerBackgroundColorG)
            userDefaults.set(newValue.cgColor?.components?[2] ?? 0.3, forKey: Strings.readerBackgroundColorB)
        }
    }
    
    public enum JapaneseTextSelectionParserMode: Int {
        case Rule
        case Basic
        case AIBasic
    }
    
    var textSelectionParserMode: JapaneseTextSelectionParserMode {
        get {
            let value = userDefaults.integer(forKey: Strings.japaneseParserMode)
            
            return JapaneseTextSelectionParserMode(rawValue: value) ?? .Rule
        }
        
        set {
            userDefaults.set(newValue.rawValue, forKey: Strings.japaneseParserMode)
        }
    }
    
    func setParserMode(value: Int) {
        textSelectionParserMode = JapaneseTextSelectionParserMode(rawValue: value) ?? .Rule
    }
    
    func changeToNextParserMode() -> JapaneseTextSelectionParserMode {
        let nextValue = textSelectionParserMode.rawValue + 1
        textSelectionParserMode = JapaneseTextSelectionParserMode(rawValue: nextValue) ?? .Rule
        return textSelectionParserMode
    }
}

extension UserDefaults {
    func bool(forKey key: String, withDefaultValue defaultValue: Bool) -> Bool {
        (object(forKey: key) as? Bool) ?? defaultValue
    }
    
    func double(forKey key: String, withDefaultValue defaultValue: Double) -> Double {
        (object(forKey: key) as? Double) ?? defaultValue
    }
}
