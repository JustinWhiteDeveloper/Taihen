import XCTest
@testable import Taihen

class TestAnkiServer: AnkiServer {
    func sendRequest(request: URLRequest, completionHandler handler: @escaping (URLResponse?, Data?, Error?) -> Void) {
        
        guard let httpBody = request.httpBody else {
            return
        }
        
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()

        if ((try? decoder.decode(CardInfoTemplate.self, from: httpBody)) != nil) {
            let result = AnkiCardInfoResult(result: [], error: nil)
            handler(nil, try? encoder.encode(result), nil)
            return
        }
        
        if ((try? decoder.decode(FindCardTemplate.self, from: httpBody)) != nil) {
            let result = AnkiQueryResult(result: [], error: nil)
            handler(nil, try? encoder.encode(result), nil)
            return
        }
        
        handler(nil, nil, nil)
    }
}

class AnkiInterfaceTests: XCTestCase {
    
    func testGivenAnAnkiInterfaceThenCardInfoCanBeRetrieved() throws {
        
        // given
        let expectedCards = AnkiCardInfoResult(result: [], error: nil)
        let interface = ConcreteAnkiInterface(server: TestAnkiServer())
        var ankiResult: AnkiCardInfoResult?
        let expectation = XCTestExpectation(description: "Wait for Response")
        
        // when
        interface.getCardInfo(values: [0,1,2]) { result in
            ankiResult = result!
            expectation.fulfill()
        }
        
        //then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(expectedCards, ankiResult)
    }
    
    func testGivenAnAnkiInterfaceThenCanFindCardsWithExpression() throws {
        
        // given
        let expectedCards = AnkiQueryResult(result: [], error: nil)
        let interface = ConcreteAnkiInterface(server: TestAnkiServer())
        var ankiResult: AnkiQueryResult?
        let expectation = XCTestExpectation(description: "Wait for Response")
        
        // when
        interface.findCards(expression: "はい") { result in
            ankiResult = result!
            expectation.fulfill()
        }
        
        //then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(expectedCards, ankiResult)
    }
    
    func testGivenAnAnkiInterfaceThenCanDoABrowseQuery() throws {
        
        // given
        let interface = ConcreteAnkiInterface(server: TestAnkiServer())
        let expectation = XCTestExpectation(description: "Wait for Response")
        
        // when
        interface.browseQuery(expression: "はい") {
            expectation.fulfill()
        }
        
        //then
        wait(for: [expectation], timeout: 1.0)
    }
}
