// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public class NetworkMonitor {
    public static let shared = NetworkMonitor()
    
    private init() {}
    
    public func startMonitoring() {
        URLProtocol.unregisterClass(CustomURLProtocol.self)
        
        guard let urlSessionClass = NSClassFromString("__NSCFURLSession") else { return }
        
        swizzleMethod(
            for: urlSessionClass,
            originalSelector: #selector(URLSession.dataTask(with:completionHandler:) as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask),
            swizzledSelector: #selector(URLSession.swizzled_dataTask(with:completionHandler:))
        )
    }
    
    private func swizzleMethod(for cls: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        guard let originalMethod = class_getInstanceMethod(cls, originalSelector),
              let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector) else { return }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

class CustomURLProtocol: URLProtocol {
    
    
}


extension URLSession {
    @objc func swizzled_dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = swizzled_dataTask(with: request) { data, response, error in
            completionHandler(data, response, error)
        }
        return task
    }
}
