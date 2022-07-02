import XCTest
import JapaneseConjugation

class DeconjugateTests: XCTestCase {

    func testCongugateTermsCorrectlyWithHardcodedRules() throws {

        let corrector = RuleListJapaneseConjugator()
        
        XCTAssertEqual(corrector.correctTerm("吊って")?.first!, "吊る")
        XCTAssertEqual(corrector.correctTerm("巻いている")?.first!, "巻く")
        XCTAssertEqual(corrector.correctTerm("古びた")?.first!, "古びる")
        XCTAssertEqual(corrector.correctTerm("運ばれてくる")?.first!, "運ぶ")
    }
    
    func testCongugateTermsCorrectlyWithRuleMap() throws {

        let corrector = RuleCollectionJapaneseConjugator()
        
        XCTAssertEqual(corrector.correctTerm("吊って")?.first!, "吊る")
        XCTAssertEqual(corrector.correctTerm("巻いている")?.first!, "巻く")
        XCTAssertEqual(corrector.correctTerm("古びた")?.first!, "古びる")
        XCTAssertEqual(corrector.correctTerm("運ばれてくる")?.first!, "運ぶ")
    }
}
