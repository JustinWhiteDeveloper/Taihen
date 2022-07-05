import Foundation

protocol AnkiClient {
    func sendRequest(request: URLRequest, completionHandler handler: @escaping (URLResponse?, Data?, Error?) -> Void)
}

class ConcreteAnkiClient: AnkiClient {
    
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
    case POST
}

class ConcreteAnkiInterface: AnkiInterface {
    
    private let client: AnkiClient
    private let address: String
    
    init(client: AnkiClient = ConcreteAnkiClient(),
         address: String = "http://localhost:8765") {
            
        self.client = client
        self.address = address
    }

    func findCards(expression: String, callback: @escaping (AnkiQueryResult?) -> Void) {
        
        guard let url = URL(string: address) else {
            callback(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        
        let template = FindCardTemplate.findCardsWithExpression(expression)
        
        let encoder = JSONEncoder()
        request.httpBody = try? encoder.encode(template)

        client.sendRequest(request: request) { (response, data, error) in
            guard let data = data else { return }
            
            let jsonDecoder = JSONDecoder()
            callback(try? jsonDecoder.decode(AnkiQueryResult.self, from: data))
        }
    }
    
    func getCardInfo(values: [Int], callback: @escaping (AnkiCardInfoResult?) -> Void) {
        guard let url = URL(string: address) else {
            callback(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        
        let template = CardInfoTemplate.getCardInfoWithCards(values)
        
        let encoder = JSONEncoder()
        request.httpBody = try? encoder.encode(template)
 
        client.sendRequest(request: request) {(response, data, error) in
            guard let data = data else { return }
            
            let jsonDecoder = JSONDecoder()
            callback(try? jsonDecoder.decode(AnkiCardInfoResult.self, from: data))
        }
    }
    
    func browseQuery(expression: String, callback: @escaping () -> Void) {
        
        guard let url = URL(string: address) else {
            callback()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        
        let template = GuiBrowseTemplate.getCardsWithQuery(expression)
        
        let encoder = JSONEncoder()
        request.httpBody = try? encoder.encode(template)

        client.sendRequest(request: request) { _, _, _ in
            callback()
        }
    }
}
