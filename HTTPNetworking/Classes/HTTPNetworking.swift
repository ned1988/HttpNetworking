//
//  HTTP.swift
//  HTTP
//
//  Created by Denys Meloshyn on 25.03.2018.
//

import Foundation

public typealias HTTPCompletionBlock = (Data?, HTTPURLResponse?, Error?) -> Void
public typealias HTTPJSONCompletionBlock = (Any?, HTTPURLResponse?, Error?) -> Void

public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

public extension URLRequest {
    var method: HTTPMethod? {
        set {
            httpMethod = newValue?.rawValue
        }
        get {
            return HTTPMethod(rawValue: httpMethod ?? "")
        }
    }
}

public extension URLComponents {
    static func httpsComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        
        return components
    }
}

public protocol HTTPProtocol {
    @discardableResult func load(_ request: URLRequest, completion: HTTPCompletionBlock?) -> URLSessionDataTask
    @discardableResult func load(_ request: URLRequest, executeCompletionBlockInMainThread: Bool, completion: HTTPCompletionBlock?) -> URLSessionDataTask
    
    @discardableResult func loadJSON(_ request: URLRequest, completion: HTTPJSONCompletionBlock?) -> URLSessionDataTask
    @discardableResult func loadJSON(_ request: URLRequest, executeCompletionBlockInMainThread: Bool, completion: HTTPJSONCompletionBlock?) -> URLSessionDataTask
}

public class HTTPNetwork: HTTPProtocol {
    public static let instance = HTTPNetwork()
    
    private let session: URLSession
    
    public init(session: URLSession = URLSession(configuration: URLSessionConfiguration.default)) {
        self.session = session
    }
    
    @discardableResult public func load(_ request: URLRequest, completion: HTTPCompletionBlock?) -> URLSessionDataTask {
        return load(request, executeCompletionBlockInMainThread: true, completion: completion)
    }
    
    @discardableResult public func load(_ request: URLRequest, executeCompletionBlockInMainThread: Bool, completion: HTTPCompletionBlock?) -> URLSessionDataTask {
        let completionResponseBlock = { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if executeCompletionBlockInMainThread {
                DispatchQueue.main.async {
                    completion?(data, response as? HTTPURLResponse, error)
                }
            } else {
                completion?(data, response as? HTTPURLResponse, error)
            }
        }
        
        let task = session.dataTask(with: request, completionHandler: completionResponseBlock)
        task.resume()
        
        return task
    }
    
    @discardableResult public func loadJSON(_ request: URLRequest, completion: HTTPJSONCompletionBlock?) -> URLSessionDataTask {
        return loadJSON(request, executeCompletionBlockInMainThread: true, completion: completion)
    }
    
    @discardableResult public func loadJSON(_ request: URLRequest, executeCompletionBlockInMainThread: Bool, completion: HTTPJSONCompletionBlock?) -> URLSessionDataTask {
        return load(request, executeCompletionBlockInMainThread: executeCompletionBlockInMainThread) { data, response, error in
            if error != nil {
                if executeCompletionBlockInMainThread {
                    DispatchQueue.main.async {
                        completion?(data, response, error)
                    }
                } else {
                    completion?(data, response, error)
                }
                return
            }
            
            guard let data = data else {
                if executeCompletionBlockInMainThread {
                    DispatchQueue.main.async {
                        completion?(nil, response, error)
                    }
                } else {
                    completion?(nil, response, error)
                }
                return
            }
            
            do {
                let result = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                if executeCompletionBlockInMainThread {
                    DispatchQueue.main.async {
                        completion?(result, response, error)
                    }
                } else {
                    completion?(result, response, error)
                }
            } catch {
                if executeCompletionBlockInMainThread {
                    DispatchQueue.main.async {
                        completion?(data, response, error)
                    }
                } else {
                    completion?(data, response, error)
                }
            }
        }
    }
}
