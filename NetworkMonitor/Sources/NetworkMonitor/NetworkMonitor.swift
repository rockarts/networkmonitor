import Foundation

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public actor NetworkMonitor {
    public static let shared = NetworkMonitor()
    
    private var isMonitoring = false
    
    private init() {}
    
    public func startMonitoring() {
        guard !isMonitoring else {
            print("Network monitoring is already active.")
            return
        }
        
        swizzleMethod(
            for: URLSession.self,
            originalSelector: #selector(URLSession.dataTask(with:completionHandler:) as (URLSession) -> (URL, @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask),
            swizzledSelector: #selector(URLSession.swizzled_dataTask(with:completionHandler:))
        )
        
        swizzleMethod(
            for: URLSession.self,
            originalSelector: #selector(URLSession.dataTask(with:completionHandler:) as (URLSession) -> (URLRequest, @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask),
            swizzledSelector: #selector(URLSession.swizzled_dataTask(withRequest:completionHandler:))
        )
        
        isMonitoring = true
        print("Network monitoring started")
    }
    
    public func stopMonitoring() {
        guard isMonitoring else {
            print("Network monitoring is not active.")
            return
        }
        
        swizzleMethod(
            for: URLSession.self,
            originalSelector: #selector(URLSession.swizzled_dataTask(with:completionHandler:)),
            swizzledSelector: #selector(URLSession.dataTask(with:completionHandler:) as (URLSession) -> (URL, @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        )
        
        swizzleMethod(
            for: URLSession.self,
            originalSelector: #selector(URLSession.swizzled_dataTask(withRequest:completionHandler:)),
            swizzledSelector: #selector(URLSession.dataTask(with:completionHandler:) as (URLSession) -> (URLRequest, @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        )
        
        isMonitoring = false
        print("Network monitoring stopped")
    }
    
    private func swizzleMethod(for cls: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        guard let originalMethod = class_getInstanceMethod(cls, originalSelector),
              let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector) else {
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension URLSession {
    
    @objc dynamic func swizzled_dataTask(withRequest request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        debugPrint("📤 Outgoing Request:")
        debugPrint("URL: \(request.url?.absoluteString ?? "")")
        debugPrint("HTTP Method: \(request.httpMethod ?? "")")
        debugPrint("Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        return self.swizzled_dataTask(withRequest: request) { data, response, error in
            debugPrint("📥 Incoming Response:")
            if let httpResponse = response as? HTTPURLResponse {
                debugPrint("Status Code: \(httpResponse.statusCode)")
                debugPrint("Headers: \(httpResponse.allHeaderFields)")
            }
            if let error = error {
                debugPrint("Error: \(error.localizedDescription)")
            }
            if let data = data {
                if let output = String(data: data, encoding: .utf8) {
                    debugPrint("Data: \(output)")
                }
                debugPrint("Data size: \(data.count) bytes")
            }
            debugPrint("---")
            
            completionHandler(data, response, error)
        }
    }
    
    @objc dynamic func swizzled_dataTask(with url: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        debugPrint("📤 Outgoing Request:")
        debugPrint("URL: \(url.absoluteString)")
        
        return self.swizzled_dataTask(with: url) { data, response, error in
            debugPrint("📥 Incoming Response:")
            if let httpResponse = response as? HTTPURLResponse {
                debugPrint("Status Code: \(httpResponse.statusCode)")
            }
            if let error = error {
                debugPrint("Error: \(error.localizedDescription)")
            }
            if let data = data {
                if let output = String(data: data, encoding: .utf8) {
                    debugPrint("Data: \(output)")
                }
                
                debugPrint("Data size: \(data.count) bytes")
            }
            debugPrint("---")
            
            completionHandler(data, response, error)
        }
    }
}
