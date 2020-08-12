//
//  WebServiceProtocol.swift
//  MLWebService
//
//  Created by Nguyen Vu Hao on 8/11/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import Foundation

public protocol WebServiceProtocol {

    /// Timeout interval for each request go through service
    var timeoutInterval: TimeInterval {get set}

    /// isEnable write log to console
    var isLogEnable: Bool {get set}
    
    /// Request HTTP
    ///
    /// - Parameters:
    ///   - method: The method request
    ///   - urlString: Full url string to request
    ///   - params: The parameters in request (optional)
    ///   - headers: The header in request (optional)
    ///   - encoding: The encoding type for response and request [.json, .xml]
    ///   - cachePolicy: The cache policy for GET request (optional)
    ///   - uploadProgressBlock: The upload request progressing block
    ///   - downloadProgressBlock: The download request progressing block
    ///   - completion: The completion block when the request be responsed
    /// - Returns: The URLSessionTask be returned for cancel or supsend
    @discardableResult
    func request(_ method: WebMethod,
                 urlString: String,
                 params: WebParams?,
                 headers: WebHeaders?,
                 encoding: WebEncoding,
                 cachePolicy: NSURLRequest.CachePolicy?,
                 uploadProgressBlock: WebProgressBlock?,
                 downloadProgressBlock: WebProgressBlock?,
                 completion: WebResultBlock?) -> URLSessionTask?


    /// Requesting HTTP
    ///
    /// - Parameters:
    ///   - request: The request information
    ///   - completion: The completion block when the request be responsed
    /// - Returns: The URLSessionTask be returned for cancel or supsend
    func request(with request: WebRequest,
                 completion: WebResultBlock?) -> URLSessionTask?


    /// Requesting upload data multipart request. Default method is POST
    ///
    /// - Parameters:
    ///   - urlString: Full url string to request
    ///   - data: The image data send request
    ///   - key: The key server will receive the data sent in request
    ///   - parameters: The parameters in request (optional)
    ///   - headers: The header in request (optional)
    ///   - progressBlock: The progress uploading block
    ///   - completion: The completion block when the request be responsed
    /// - Returns: The URLSessionUploadTask be returned for cancel or supsend
    @discardableResult
    func uploadDataMultipart(_ urlString: String,
                             data: Data,
                             key: String,
                             parameters: [String:Any]?,
                             headers: WebHeaders?,
                             progressBlock: WebProgressBlock?,
                             completion: WebResultBlock?) -> URLSessionDataTask?

    /// Requesting upload multipart data
    ///
    /// - Parameters:
    ///   - multipart: The mutipartRequest
    ///   - progressBlock: The progress uploading block
    ///   - completion: The completion block when the request be responsed
    /// - Returns: The URLSessionUploadTask be returned for cancel or supsend
    @discardableResult
    func requestUploadMultipart(_ multipart: WebMultipartRequest,
                                progressBlock: WebProgressBlock?,
                                completion: WebResultBlock?) -> URLSessionDataTask?

    /// The logger protocol. Implement it when you wanna change log service
    ///
    /// - Parameter text: The text request to log
    func httpLog(_ text: String)
}

public extension WebServiceProtocol {


    /// The function utility for request by json encoding wil no header, and progress block
    ///
    /// - Parameters:
    ///   - method: The method request
    ///   - urlString: Full url string to request
    ///   - params: The parameters in request (optional)
    ///   - completion: The completion block when the request be responsed
    /// - Returns: The URLSessionTask be returned for cancel or supsend
    @discardableResult
    func requestJSON(_ method: WebMethod,
                     urlString: String,
                     params: WebParams?,
                     completion: WebResultBlock?) -> URLSessionTask? {

        return request(method, urlString: urlString,
                       params: params,
                       headers: nil,
                       encoding: .json,
                       cachePolicy: nil,
                       uploadProgressBlock: nil,
                       downloadProgressBlock: nil,
                       completion: completion)
    }

}

