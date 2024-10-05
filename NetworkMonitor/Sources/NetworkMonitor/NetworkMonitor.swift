import Foundation

public class NetworkMonitor {
    public static let shared = NetworkMonitor()
    
    private init() {}
    
    public func startMonitoring() {
        URLProtocol.registerClass(MonitorURLProtocol.self)
        
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.protocolClasses = [MonitorURLProtocol.self] + (sessionConfiguration.protocolClasses ?? [])
        
        URLSession.shared = URLSession(configuration: sessionConfiguration)
        
        print("Network monitoring started")
    }
}

class MonitorURLProtocol: URLProtocol {
    static var requestCount = 0
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        MonitorURLProtocol.requestCount += 1
        let requestId = MonitorURLProtocol.requestCount
        
        print("📤 Outgoing Request #\(requestId):")
        print("URL: \(request.url?.absoluteString ?? "Unknown")")
        print("Method: \(request.httpMethod ?? "Unknown")")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        if let httpBody = request.httpBody, let bodyString = String(data: httpBody, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
        print("---")
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            print("📥 Incoming Response #\(requestId):")
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
                print("Headers: \(httpResponse.allHeaderFields)")
            }
            
            if let data = data, let stringData = String(data: data, encoding: .utf8) {
                print("Response data:")
                print(stringData)
            } else {
                print("No data received or unable to convert data to string")
            }
            print("---")
            
            if let response = response {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let data = data {
                self.client?.urlProtocol(self, didLoad: data)
            }
            
            if let error = error {
                self.client?.urlProtocol(self, didFailWithError: error)
            }
            
            self.client?.urlProtocolDidFinishLoading(self)
        }
        task.resume()
    }
    
    override func stopLoading() {
    }
}

extension URLSession {
    static var shared: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MonitorURLProtocol.self] + (configuration.protocolClasses ?? [])
        return URLSession(configuration: configuration)
    }()
}
