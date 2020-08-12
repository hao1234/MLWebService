//
//  WebProvider.swift
//  MLWebService
//
//  Created by Nguyen Vu Hao on 8/11/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import Foundation

open class WebProvider: WebProviderProtocol {
    
    public let webService: WebServiceProtocol
    public fileprivate(set) var baseAddress: String
    public var header: WebServiceHeaderProtocol?
    open var interruptionService: InterruptionWebServiceProtocol?
    
    public init(webService: WebServiceProtocol,
                header: WebServiceHeaderProtocol?,
                interruption: InterruptionWebServiceProtocol?,
                baseAddress: String) {
        
        self.baseAddress = baseAddress
        self.webService = webService
        self.header = header
        self.interruptionService = interruption
    }
    
}

// MARK: WebProviderProtocol
public extension WebProvider {
    
    @discardableResult
    func request(method: WebMethod,
                 path: String,
                 headers: WebHeaders?,
                 params: WebParams?,
                 encoding: WebEncoding,
                 cachePolicy: NSURLRequest.CachePolicy?,
                 uploadProgressBlock: WebProgressBlock?,
                 downloadProgressBlock: WebProgressBlock?,
                 timeoutInterval: TimeInterval?,
                 completion: WebResultBlock?) -> URLSessionTask? {
        
        let request = WebRequest(method: method,
                                 urlString: path,
                                 encoding: encoding,
                                 params: params,
                                 headers: headers,
                                 cachePolicy: cachePolicy,
                                 uploadProgressBlock: uploadProgressBlock,
                                 downloadProgressBlock: downloadProgressBlock,
                                 timeoutInterval: timeoutInterval)
        
        return self.request(with: request, completion: completion)
    }
    
    func request(with request: WebRequest,
                 completion: WebResultBlock?) -> URLSessionTask? {
        
        let urlString = fullURLString(forPath: request.urlString)
        request.urlString = urlString
        let headers = synthesizeHeaders(request.headers, request: request)
        request.headers = headers
        
        return webService.request(with: request) { result in
            completion?(result)
        }
    }
    
    func requestUploadDataMultipart(path: String,
                                    data: Data,
                                    key: String,
                                    parameters: [String:Any]?,
                                    headers: WebHeaders?,
                                    progressBlock: WebProgressBlock?,
                                    completion: WebResultBlock?) -> URLSessionDataTask? {
        
        let urlString = fullURLString(forPath: path)
        let headers = synthesizeHeaders(
            headers,
            request: WebRequest(method: .post, urlString: urlString)
        )
        
        return webService.uploadDataMultipart(
            urlString,
            data: data,
            key: key,
            parameters: parameters,
            headers: headers,
            progressBlock: progressBlock,
            completion: { result in
                completion?(result)
        })
    }
    
    func uploadDataMultipart(request: WebMultipartRequest,
                             progressBlock: WebProgressBlock?,
                             completion: WebResultBlock?) -> URLSessionDataTask? {
        
        var request = request
        request.urlString = fullURLString(forPath: request.urlString)
        request.headers = synthesizeHeaders(request.headers, request: WebRequest(method: .post, urlString: request.urlString))
        
        return webService.requestUploadMultipart(request,
                                                 progressBlock: progressBlock,
                                                 completion: completion)
    }

    func updateBaseAddress(_ address: String) {
        self.baseAddress = address
    }
}

// MARK: Private API's
fileprivate extension WebProvider {

    func fullURLString(forPath path: String) -> String {
        if path.contains(baseAddress) {
            return path
        }
        return baseAddress + "/" + path
    }
    
    func synthesizeHeaders(_ headers: WebHeaders?, request: WebRequest) -> WebHeaders? {
        
        let defaultHeaders = self.defaultHeaders(request: request)
        guard let headers = headers else {
            return defaultHeaders
        }
        
        var mutableHeaders = headers
        defaultHeaders.forEach { (key, value) in
            mutableHeaders[key] = value
        }
        
        return mutableHeaders
    }
    
    func defaultHeaders(request: WebRequest) -> WebHeaders {
        return self.header?.getHeaderInRequest(request) ?? [:]
    }
}

