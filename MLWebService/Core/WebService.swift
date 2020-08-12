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
        guard let urlRequest = generateURLRequest(from: request) else {
            completion?(Results(withError: WebError.unknown("")))
            return nil
        }
        
        let task = session.dataTask(with: urlRequest) { data, responseObject, error in
            let result = Results(
                withData: data,
                response: Response(fromURLResponse: responseObject),
                error: error
            )
            self.httpLog("Reponse: \(request.urlString) \n \(result.data?.string ?? "empty")")
            self.completeQueue.async { completion?(result) }
        }
        DispatchQueue.global().async {
            task.resume()
        }
        return task
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
    func requestUploadMultipart(
        _ multipart: WebMultipartRequest,
        progressBlock: WebProgressBlock?,
        completion: WebResultBlock?) -> URLSessionDataTask? {
        guard let urlRequest = multipartFormRequestWithMethod(
            .post,
            urlString: multipart.urlString,
            multipart: multipart) else {
            completion?(Results(withError: WebError.unknown("")))
            return nil
        }
        let task = session.dataTask(with: urlRequest) { data, responseObject, error in
            self.completeQueue.async { completion?(Results(
                withData: data,
                response: Response(fromURLResponse: responseObject),
                error: error
            )) }
        }
        DispatchQueue.global().async {
            task.resume()
        }
        return task
    }
    
    func uploadDataMultipart(
        _ urlString: String,
        data: Data,
        key: String,
        parameters: [String:Any]?,
        headers: WebHeaders?,
        progressBlock: WebProgressBlock?,
        completion: WebResultBlock?
    ) -> URLSessionDataTask? {
        
        let multipartData = WebMultipartData(data: data,
                                             name: key,
                                             fileName: UUID().uuidString,
                                             mimeType: "image/jpg")
        let multipartRequest = WebMultipartRequest(urlString: urlString,
                                                   data: [multipartData],
                                                   parameters: parameters,
                                                   headers: headers)
        
        return requestUploadMultipart(multipartRequest,
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
    
    func generateURLRequest(from requestModel: WebRequest) -> URLRequest? {
        // Query string param
        guard let url = URL(string: requestModel.urlString) else {
            return nil
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
                    else {
                        return nil
                }
                urlcomponent.queryItems = params.reduce([])
                { (result, element) -> [URLQueryItem] in
                    let (key, value) = element
                    let queryItem = URLQueryItem(name: key, value: "\(value)")
                    return result + [queryItem]
                }
                guard let url = urlcomponent.url else {
                    return nil

                }
                urlRequest.url = url
            }
        } // Body params
        else {
            urlRequest.httpBody = parseParams(requestModel.params ?? [:], encoding: requestModel.encoding)
        }
        self.logRequest(url, method: requestModel.method, encoding: requestModel.encoding, data: urlRequest.httpBody)
        return urlRequest
    }
    
    func multipartFormRequestWithMethod(
        _ method: WebMethod,
        urlString: String,
        multipart: WebMultipartRequest
    ) -> URLRequest? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let boundary = generateBoundaryString()
        let body = createBodyWithParameters(multipart.parameters, data: multipart.data, boundary: boundary)
        urlRequest.httpBody = body
        urlRequest.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        
        // Headers
        multipart.headers?.forEach{ urlRequest.setValue($1, forHTTPHeaderField: $0) }
        return urlRequest
    }
    
    func createBodyWithParameters(
        _ parameters: WebParams?,
        data: [WebMultipartProtocol],
        boundary: String
    ) -> Data {
        let body = NSMutableData()
        guard let arrData = data as? [WebMultipartData] else { return body as Data }
        
        if let parameters = parameters {
            for (key, value) in parameters {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        arrData.filter{ $0.data != nil }.forEach {
            let mimetype = $0.mimeType
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"fileUpload\"; filename=\"\"\r\n")
            body.appendString("Content-Type: \(mimetype)\r\n\r\n")
            body.append($0.data!)
            body.appendString("\r\n")
            body.appendString("--\(boundary)--\r\n")
        }
    
        return body as Data
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
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
