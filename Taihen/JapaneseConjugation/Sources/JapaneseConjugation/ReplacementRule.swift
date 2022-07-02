import Foundation

public struct ReplacementRule {
    public var term: String
    public var replacements: [String]
    
    public func replacementStrings(_ text: String) -> [String] {
        
        var result: [String] = []
        
        for replacement in replacements {
            var search = text
            search.removeLast(term.count)
            search.append(replacement)
            result.append(search)
        }
    
        return result
    }
    
    public func attemptReplace(_ text: String) -> [String]? {
        
        if text.endsWithText(term) {
            return replacementStrings(text)
        }
        
        return nil
    }
}
