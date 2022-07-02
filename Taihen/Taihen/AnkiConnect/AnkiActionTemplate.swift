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

struct AnkiQueryResult: Codable, Equatable {
    var result: [Int]
    var error: String?
}

struct AnkiCardInfoResultItem: Codable, Equatable {
    var cardId: Int
    var due: Int
}

struct AnkiCardInfoResult: Codable, Equatable {
    var result: [AnkiCardInfoResultItem]
    var error: String?
}

protocol AnkiServer {
    func sendRequest(request: URLRequest, completionHandler handler: @escaping (URLResponse?, Data?, Error?) -> Void)
}

class ConcreteAnkiServer: AnkiServer {
    
    init() {}
    
    func sendRequest(request: URLRequest, completionHandler handler: @escaping (URLResponse?, Data?, Error?) -> Void) {
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: handler)
    }
}

protocol AnkiInterface {
    func findCards(expression: String, callback: @escaping (AnkiQueryResult?) -> Void)
    func getCardInfo(values: [Int], callback: @escaping (AnkiCardInfoResult?) -> Void)
    func browseQuery(expression: String, callback: @escaping () -> Void)
}

private enum HTTPMethod: String {
    case Post = "POST"
}

class ConcreteAnkiInterface: AnkiInterface {
    
    private let address = "http://localhost:8765"
    
    private let server: AnkiServer
    
    init(server: AnkiServer = ConcreteAnkiServer()) {
        self.server = server
    }

    func findCards(expression: String, callback: @escaping (AnkiQueryResult?) -> Void) {
        
        guard let url = URL(string: address) else {
            callback(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.Post.rawValue
        
        let template = FindCardTemplate.findCardsWithExpression(expression)
        
        let encoder = JSONEncoder()

        do {
            request.httpBody = try encoder.encode(template)
        }
        catch {
            callback(nil)
        }
        
        server.sendRequest(request: request) { (response, data, error) in
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
        guard let url = URL(string: address) else {
            callback(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.Post.rawValue
        
        let template = CardInfoTemplate.getCardInfoWithCards(values)
        
        let encoder = JSONEncoder()
    
        do {
            request.httpBody = try encoder.encode(template)
        }
        catch {
            callback(nil)
        }
        
        server.sendRequest(request: request) {(response, data, error) in
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
    
    func browseQuery(expression: String, callback: @escaping () -> Void) {
        
        guard let url = URL(string: address) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.Post.rawValue
        
        let template = GuiBrowseTemplate.getCardsWithQuery(expression)
        
        let encoder = JSONEncoder()
    
        do {
            request.httpBody = try encoder.encode(template)
        }
        catch { }
        
        server.sendRequest(request: request) {_,_,_ in
            callback()
        }
    }
}
