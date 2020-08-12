//
//  WebProviderProtocol.swift
//  MLWebService
//
//  Created by Nguyen Vu Hao on 8/11/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import Foundation

public protocol WebProviderProtocol {

    /// The webservice is used
    var webService: WebServiceProtocol {get}

    /// The request header provider
    var header: WebServiceHeaderProtocol? {get}

    /// The interruption service
    var interruptionService: InterruptionWebServiceProtocol? {get}

    /// The base address use for each request
    var baseAddress: String {get}

    /// Request HTTP using WebServiceProtocol be implemented
    ///
    /// - Parameters:
    ///   - method: The method request
    ///   - path: The api path to request fullpath should be: baseAddress + "/" + path
    ///   - params: The parameters in request (optional)
    ///   - headers: The header in request (optional)
    ///   - encoding: The encoding type for response and request [.json, .xml]
    ///   - cachePolicy: The cache policy for GET request (optional)
    ///   - uploadProgressBlock: The upload request progressing block
    ///   - downloadProgressBlock: The download request progressing block
    ///   - timeoutInterval: The request interval timeout
    ///   - completion: The completion block when the request be responsed
    /// - Returns: The URLSessionTask be returned for cancel or supsend
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
                 completion: WebResultBlock?) -> URLSessionTask?

    /// Request HTTP
    ///
    /// - Parameters:
    ///   - request: The request information
    ///   - completion: The completion block when the request be responsed
    /// - Returns: The URLSessionTask be returned for cancel or supsend
    func request(with request: WebRequest,
                 completion: WebResultBlock?) -> URLSessionTask?

    /// Upload single data or data multipart request using WebServiceProtocol be implemented. Default method is POST
    ///
    /// - Parameters:
    ///   - path: The api path to request. Fullpath should be: baseAddress + "/" + path
    ///   - data: The data send request
    ///   - key: The key server will receive the data sent in request
    ///   - parameters: The parameters in request (optional)
    ///   - headers: The header in request (optional)
    ///   - progressBlock: The progress uploading block
    ///   - completion: The completion block when the request be responsed
    /// - Returns: The URLSessionUploadTask be returned for cancel or supsend
    @discardableResult
    func requestUploadDataMultipart(path: String,
                                    data: Data,
                                    key: String,
                                    parameters: [String:Any]?,
                                    headers: WebHeaders?,
                                    progressBlock: WebProgressBlock?,
                                    completion: WebResultBlock?) -> URLSessionDataTask?

    /// Requesting upload single image or data multipart request. Default method is POST
    ///
    /// - Parameters:
    ///   - request: The mutipart request
    ///   - progressBlock: The progress uploading block
    ///   - completion: The completion block when the request be responsed
    /// - Returns: The URLSessionUploadTask be returned for cancel or supsend
    @discardableResult
    func uploadDataMultipart(request: WebMultipartRequest,
                             progressBlock: WebProgressBlock?,
                             completion: WebResultBlock?) -> URLSessionDataTask?

    /// Update base address
    ///
    /// - Parameter address: The new base address to update
    func updateBaseAddress(_ address: String)
}

/// WebServiceHeaderProtocol use to get header for each request with information
public protocol WebServiceHeaderProtocol {
    /// Get headers
    ///
    /// - Parameters:
    ///   - urlString: The URL string request get header
    ///   - method: The method request get header
    ///   - encoding: The encoding request get header
    /// - Returns: The header for this request
    func getHeaderInRequest(_ request: WebRequest) -> WebHeaders?
}


public typealias RetryInteruptionBlock = () -> Void
/// InterruptionWebServiceProtocol use to interruption when receive error code such as: error_access_token, error_force_update. Implement this protocol for handling to expected error code
public protocol InterruptionWebServiceProtocol {


    /// Handle interruption error code
    ///
    /// - Parameter result: The result of error code
    /// - Returns: Return "true" to ignore all response from this request
    func handleInterruption(request: WebRequest?, result: String, retryBlock: RetryInteruptionBlock?) -> Bool

}
