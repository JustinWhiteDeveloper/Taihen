import Foundation

public protocol JPConjugator {
    func correctTerm(_ term: String) -> [String]?
}
