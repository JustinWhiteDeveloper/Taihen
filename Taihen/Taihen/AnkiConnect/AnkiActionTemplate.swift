import Foundation

class FindCardTemplate: Codable {
    var action: String
    var version: Int
    var params: [String: String]
    
    init(action: String, version: Int, params: [String: String]) {
        self.action = action
        self.version = version
        self.params = params
    }
}

class CardInfoTemplate: Codable {
    var action: String
    var version: Int
    var params: [String: [Int]]
    
    init(action: String, version: Int, params: [String: [Int]]) {
        self.action = action
        self.version = version
        self.params = params
    }
}

class GuiBrowseTemplate: Codable {
    var action: String
    var version: Int
    var params: [String: String]
    
    init(action: String, version: Int, params: [String: String]) {
        self.action = action
        self.version = version
        self.params = params
    }
}

extension FindCardTemplate {
    static func findCardsWithExpression(_ expression: String) -> FindCardTemplate {
        return FindCardTemplate(action: "findCards", version: 6, params: ["query":expression])
    }
}

extension CardInfoTemplate {
    static func getCardInfoWithCards(_ cards: [Int]) -> CardInfoTemplate {
        return CardInfoTemplate(action: "cardsInfo", version: 6, params: ["cards":cards])
    }
}


extension GuiBrowseTemplate {
    static func getCardsWithQuery(_ query: String) -> GuiBrowseTemplate {
        return GuiBrowseTemplate(action: "guiBrowse", version: 6, params: ["query":query])
    }
}

struct AnkiQueryResult: Codable {
    var result: [Int]
    var error: String?
}

struct AnkiCardInfoResultItem: Codable {
    var cardId: Int
    var due: Int
}


struct AnkiCardInfoResult: Codable {
    var result: [AnkiCardInfoResultItem]
    var error: String?
}

class AnkiSearcher {
    
    private let localServerAddress = "http://localhost:8765"
    private let httpMethod = "POST"
    
    func findCards(expression: String, callback: @escaping (AnkiQueryResult?) -> Void) {
        let url = URL(string: localServerAddress)!
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        let template = FindCardTemplate.findCardsWithExpression(expression)
        
        let encoder = JSONEncoder()

        do {
            request.httpBody = try encoder.encode(template)
        }
        catch {
            callback(nil)
        }
        
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {(response, data, error) in
            guard let data = data else { return }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let template = try jsonDecoder.decode(AnkiQueryResult.self, from: data)
                callback(template)

            }
            catch {
                callback(nil)
            }
        }
    }
    
    func getCardInfo(values: [Int], callback: @escaping (AnkiCardInfoResult?) -> Void) {
        let url = URL(string: localServerAddress)!
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        let template = CardInfoTemplate.getCardInfoWithCards(values)
        
        let encoder = JSONEncoder()
    
        do {
            request.httpBody = try encoder.encode(template)
        }
        catch {
            callback(nil)
        }
        
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {(response, data, error) in
            guard let data = data else { return }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let template = try jsonDecoder.decode(AnkiCardInfoResult.self, from: data)
                callback(template)
            }
            catch {
                callback(nil)
            }
        }
    }
    
    func browseQuery(expression: String) {
        let url = URL(string: localServerAddress)!
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        let template = GuiBrowseTemplate.getCardsWithQuery(expression)
        
        let encoder = JSONEncoder()
    
        do {
            request.httpBody = try encoder.encode(template)
        }
        catch { }
        
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {_,_,_ in }
    }
}
