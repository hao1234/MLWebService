//
//  WebRequest.swift
//  MLWebService
//
//  Created by Nguyen Vu Hao on 8/11/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import Foundation

open class WebRequest {

    public struct Key {
        static var nonce = "nonce"
    }

    open var method: WebMethod
    open var urlString: String
    open var encoding: WebEncoding

    open var params: WebParams? = nil
    open var headers: WebHeaders? = nil
    open var cachePolicy: NSURLRequest.CachePolicy? = nil
    open var uploadProgressBlock: WebProgressBlock? = nil
    open var downloadProgressBlock: WebProgressBlock? = nil
    open var timeoutInterval: TimeInterval?
    open fileprivate(set) var retryCount: UInt = 0

    public init(method: WebMethod,
                urlString: String,
                encoding: WebEncoding = .json,
                params: WebParams? = nil) {
        
        self.method = method
        self.urlString = urlString
        self.encoding = encoding
        self.params = params
    }

    public init(method: WebMethod,
                urlString: String,
                encoding: WebEncoding,
                params: WebParams? = nil,
                headers: WebHeaders? = nil,
                cachePolicy: NSURLRequest.CachePolicy? = nil,
                uploadProgressBlock: WebProgressBlock? = nil,
                downloadProgressBlock: WebProgressBlock? = nil,
                timeoutInterval: TimeInterval? = nil) {

        self.method = method
        self.urlString = urlString
        self.encoding = encoding
        self.params = params
        self.headers = headers
        self.cachePolicy = cachePolicy
        self.downloadProgressBlock = downloadProgressBlock
        self.uploadProgressBlock = uploadProgressBlock
        self.timeoutInterval = timeoutInterval
    }

    open func increaseRetryCount() {
        self.retryCount += 1
    }

    open func getNonce() -> String? {
        return params?[Key.nonce] as? String
    }
}
