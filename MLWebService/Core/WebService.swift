//
//  WebService.swift
//  MLWebService
//
//  Created by Nguyen Vu Hao on 8/11/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import Foundation

/// Base implementation WebServiceProtocol
open class WebService: WebServiceProtocol {
    
    open var timeoutInterval: TimeInterval = 10.0
    open var isLogEnable: Bool = true
    let session: URLSession = URLSession.shared
    open var completeQueue: DispatchQueue = .main
    
    public init(completionBlockQueue: DispatchQueue = .main) {
        self.completeQueue = completionBlockQueue
        
        #if RELEASE
        self.isLogEnable = false
        #endif
    }
    
    open func httpLog(_ text: String) {
        if isLogEnable {
            print(text)
        }
    }
}

// MARK: - Request
public extension WebService {
    
    @discardableResult
    func request(with request: WebRequest,
                 completion: WebResultBlock?) -> URLSessionTask? {
        do {
            let urlRequest = try self.generateURLRequest(from: request)
            let task = session.dataTask(with: urlRequest) { data, responseObject, error in
                self.completeQueue.async { completion?(Results(
                    withData: data,
                    response: Response(fromURLResponse: responseObject),
                    error: error
                )) }
            }
            return task
        } catch let error {
            self.completeQueue.async { completion?(Results(withError: error)) }
            return nil
        }
    }
    
    @discardableResult
    func request(_ method: WebMethod,
                 urlString: String,
                 params: WebParams?,
                 headers: WebHeaders?,
                 encoding: WebEncoding,
                 cachePolicy: NSURLRequest.CachePolicy?,
                 uploadProgressBlock: WebProgressBlock?,
                 downloadProgressBlock: WebProgressBlock?,
                 completion: WebResultBlock?) -> URLSessionTask? {
        
        let request = WebRequest(method: method,
                                 urlString: urlString,
                                 encoding: encoding,
                                 params: params,
                                 headers: headers,
                                 cachePolicy: cachePolicy,
                                 uploadProgressBlock: uploadProgressBlock,
                                 downloadProgressBlock: downloadProgressBlock)
        
        return self.request(with: request, completion: completion)
    }
    
    fileprivate func logRequest(_ url: URL, method: WebMethod, encoding: WebEncoding, data: Data?) {
        if isLogEnable == false {
            return
        }
        var postJson: [String: Any]?
        if let data = data,
            method == .post && encoding == .json
        {
            do {
                postJson = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] ?? [:]
            } catch {}
        }
        
        if let postJson = postJson {
            self.httpLog("Request: \(url.absoluteString) \n \(postJson.json())")
        } else {
            self.httpLog("Request: \(url.absoluteString)")
        }
    }
}

// MARK: Multi-part
public extension WebService {
    
    @discardableResult
    func requestUploadMultipart(_ multipart: WebMultipartRequest,
                                progressBlock: WebProgressBlock?,
                                completion: WebResultBlock?) -> URLSessionUploadTask? {
        return nil
    }
    
    func uploadDataMultipart(_ urlString: String,
                             data: Data,
                             key: String,
                             parameters: [String:Any]?,
                             headers: WebHeaders?,
                             progressBlock: WebProgressBlock?,
                             completion: WebResultBlock?) -> URLSessionUploadTask? {
        
        let multipartData = WebMultipartData(data: data,
                                             name: key,
                                             fileName: UUID().uuidString,
                                             mimeType: "image/jpg")
        let multipartRequest = WebMultipartRequest(urlString: urlString,
                                                   data: [multipartData],
                                                   parameters: parameters, headers: headers)
        
        return self.requestUploadMultipart(multipartRequest,
                                           progressBlock: progressBlock,
                                           completion: completion)
    }
}

// MARK: Parser
fileprivate extension WebService {
    func parseParams(_ params: WebParams, encoding: WebEncoding) -> Data? {
        switch encoding {
        case .json: return parseJSONParams(params)
        default:
            return nil
        }
    }
    
    func parseJSONParams(_ params: WebParams) -> Data? {
        return try? JSONSerialization.data(withJSONObject: params, options: .init(rawValue: 0))
    }
    
    func generateURLRequest(from requestModel: WebRequest) throws -> URLRequest {
        // Query string param
        guard let url = URL(string: requestModel.urlString) else {
            throw WebError.unknown("Invalid url \(requestModel.urlString)")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = requestModel.method.rawValue
        if requestModel.encoding == .json {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } else {
            urlRequest.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        }
        if let cachePolicy = requestModel.cachePolicy {
            urlRequest.cachePolicy = cachePolicy
        }
        
        // Headers
        requestModel.headers?.forEach{ urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
        // Query string param
        if requestModel.method == .get {
            if let params = requestModel.params {
                guard
                    var urlcomponent = URLComponents(string: requestModel.urlString)
                    else { throw WebError.unknown("Invalid url \(requestModel.urlString)") }
                urlcomponent.queryItems = params.reduce([])
                { (result, element) -> [URLQueryItem] in
                    let (key, value) = element
                    let queryItem = URLQueryItem(name: key, value: "\(value)")
                    return result + [queryItem]
                }
                guard let url = urlcomponent.url else { throw WebError.unknown("Invalid url \(requestModel.urlString)") }
                urlRequest.url = url
            }
        } // Body params
        else {
            urlRequest.httpBody = parseParams(requestModel.params ?? [:], encoding: requestModel.encoding)
        }
        self.logRequest(url, method: requestModel.method, encoding: requestModel.encoding, data: urlRequest.httpBody)
        return urlRequest
    }
}

// MARK: - Collection Extension for print Dictionary object
fileprivate extension Dictionary {
    
    /// Convert self to JSON String.
    /// - Returns: Returns the JSON as String or empty string if error while parsing.
    func json() -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            guard let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) else {
                return "{}"
            }
            return jsonString
        } catch {
            return "{}"
        }
    }
}
