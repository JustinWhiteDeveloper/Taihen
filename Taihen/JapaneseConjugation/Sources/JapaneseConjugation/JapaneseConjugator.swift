import Foundation

public protocol JapaneseConjugator {
    func correctTerm(_ term: String) -> [String]?
}
