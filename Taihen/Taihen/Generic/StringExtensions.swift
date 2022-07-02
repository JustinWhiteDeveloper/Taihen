import Foundation
import CryptoKit

extension String {
    
    private enum Constants {
        static let validJapaneseCharacterRegex = "[\u{3040}-\u{3094}\u{30A1}-\u{30FA}\u{3400}-\u{4dbf}\u{4e00}-\u{9fff}\u{f900}-\u{faff}]"
        
        static let validKanjiRegex = "[\u{3400}-\u{4dbf}\u{4e00}-\u{9fff}]"
        
        static let validHiraganaRegex = "[\u{3040}-\u{30FF}]"
    }
    
    var containsValidJapaneseCharacters: Bool {
        return self.range(of: Constants.validJapaneseCharacterRegex, options: String.CompareOptions.regularExpression) != nil
    }
    
    var containsKanji: Bool {
        return self.range(of: Constants.validKanjiRegex, options: String.CompareOptions.regularExpression) != nil
    }
    
    var containsHiragana: Bool {
        return self.range(of: Constants.validHiraganaRegex, options: String.CompareOptions.regularExpression) != nil
    }
    
    func trimingTrailingSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        guard let index = lastIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: characterSet) }) else {
            return self
        }

        return String(self[...index])
    }
    
    var md5: String {
        let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())

        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
    
    func endsWith(_ text: String) -> Bool {
        return self.range(of: "^.*\(text)$", options: String.CompareOptions.regularExpression) != nil
    }

    subscript (_ range: NSRange) -> Self {
        .init(self[index(startIndex, offsetBy: range.lowerBound) ..< index(startIndex, offsetBy: range.upperBound)])
    }
}
