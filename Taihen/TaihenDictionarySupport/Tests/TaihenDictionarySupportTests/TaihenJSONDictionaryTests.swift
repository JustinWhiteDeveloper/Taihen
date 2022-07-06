import XCTest
@testable import TaihenDictionarySupport

final class TaihenDictionaryTests: XCTestCase {
    
    func testGivenADictionaryReaderAndTheJMDictFolderThenTheDataIsReadCorrectly() {
        
        //given
        let expectedFirstTag = TaihenJSONDictionaryTag(shortName: "news",
                                                    extraInfo: "frequent",
                                                    color: -2,
                                                    tagDescription: "appears frequently in Mainichi Shimbun",
                                                    piority: 0)
        
        let expectedFirstTerm = TaihenJSONDictionaryTerm(term: "ヽ",
                                                         kana: "",
                                                         definitionTags: ["unc"],
                                                         explicitType: "",
                                                         unknownInteger: 2,
                                                         meanings: ["repetition mark in katakana"],
                                                         extraMeanings: [],
                                                         index: 1000000,
                                                         classifications: [""])
        
        let expectedLastTermMeaning = "Japanese-Multilingual Dictionary Project - Creation Date: 2021-01-01"
        
        let expectedLastTerm = TaihenJSONDictionaryTerm(term: "ＪＭｄｉｃｔ",
                                                        kana: "ジェイエムディクト",
                                                        definitionTags: ["unc"],
                                                        explicitType: "",
                                                        unknownInteger: 1,
                                                        meanings: [expectedLastTermMeaning],
                                                        extraMeanings: [],
                                                        index: 9999999,
                                                        classifications: [""])
        
        let reader = ConcreteTaihenJSONDictionaryReader()
        
        //when
        let dictionary = reader.readFolder(bundle: Bundle.module, subPath: "Dictionaries/jmdict_english")!

        //then
        XCTAssertEqual(dictionary.name, "JMdict (English)")
        XCTAssertEqual(dictionary.revision, "jmdict4")
        XCTAssertTrue(dictionary.sequenced)
        XCTAssertEqual(dictionary.format, 3)
        XCTAssertEqual(dictionary.tags.first, expectedFirstTag)
        XCTAssertEqual(dictionary.tags.count, 237)
        XCTAssertEqual(dictionary.terms.first, expectedFirstTerm)
        XCTAssertEqual(dictionary.terms.last, expectedLastTerm)
        XCTAssertEqual(dictionary.terms.count, 314984)
    }
    
    func testGivenADictionaryWriterConvertCustomFormat() {
        
        //given
        let reader = ConcreteTaihenJSONDictionaryReader()
        
        //when
        let dictionary = reader.readFolder(bundle: Bundle.module, subPath: "Dictionaries/jmdict_english")!
        let dictionary2 = TaihenDictionaryBridge().convertJsonToCustom(dictionary: dictionary)!
                
        //then
        XCTAssertEqual(dictionary2.name, "JMdict (English)")
        XCTAssertEqual(dictionary2.revision, "jmdict4")
        XCTAssertEqual(dictionary2.tags.count, 237)
        XCTAssertEqual(dictionary2.terms.count, 314984)
    }
    
    func testGivenACondensedDictionaryReader() {
        
        //given
        let reader = ConcreteTaihenJSONDictionaryReader()
        let dictionary = reader.readFolder(bundle: Bundle.module, subPath: "Dictionaries/jmdict_english")!
        var dictionary2 = TaihenDictionaryBridge()
                                .convertJsonToCustom(dictionary: dictionary)!
        
        // write part of results to file for reader test
        dictionary2.name = "1000 terms"
        dictionary2.revision = "test"
        dictionary2.terms.removeLast(dictionary2.terms.count - 1000)
        
        let path = Bundle.module.bundlePath + "/Contents/Resources/condensed_part.json"
        let writer = ConcreteTaihenCustomDictionaryWriter()
        let reader2 = ConcreteTaihenCustomDictionaryReader()
        
        //when
        writer.write(dictionary: dictionary2 as! ConcreteTaihenCustomDictionary, path: path)
        let dictionary3 = reader2.readFile(path: path)!
        
        //then
        XCTAssertEqual(dictionary3.name, "1000 terms")
        XCTAssertEqual(dictionary3.revision, "test")
        XCTAssertEqual(dictionary3.tags.count, 237)
        XCTAssertEqual(dictionary3.terms.count, 1000)
    }
}
