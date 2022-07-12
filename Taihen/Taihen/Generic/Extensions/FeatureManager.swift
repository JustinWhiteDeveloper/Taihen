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
    
    static let deckName = "DeckName"
    static let noteType = "noteType"

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
            userDefaults.double(forKey: Strings.readerTextSize,
                                        withDefaultValue: Sizings.defaultTextSize)
        }
        
        set {
            userDefaults.set(newValue, forKey: Strings.readerTextSize)
        }
    }
    
    var dictionaryTextSize: Double {
        get {
            userDefaults.double(forKey: Strings.dictionaryTextSize,
                                        withDefaultValue: Sizings.defaultTextSize)
        }
        
        set {
            userDefaults.set(newValue, forKey: Strings.dictionaryTextSize)
        }
    }
    
    var deckName: String {
        get {
            userDefaults.string(forKey: Strings.deckName, withDefaultValue: "Default")
        }
        
        set {
            userDefaults.set(newValue, forKey: Strings.deckName)
        }
    }
    
    var noteType: String {
        get {
            userDefaults.string(forKey: Strings.noteType, withDefaultValue: "Basic")
        }
        
        set {
            userDefaults.set(newValue, forKey: Strings.noteType)
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
    
    var isDebugMode: Bool {
#if DEBUG
    return true
#else
    return false
#endif
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
    
    func string(forKey key: String, withDefaultValue defaultValue: String) -> String {
        (object(forKey: key) as? String) ?? defaultValue
    }
}
