//
//  WebMultipartRequest.swift
//  MLWebService
//
//  Created by Nguyen Vu Hao on 8/11/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import Foundation

public struct WebMultipartRequest {

    public var urlString: String
    public var data: [WebMultipartProtocol]
    public var parameters: WebParams?
    public var headers: WebHeaders?

    public init(
        urlString: String,
        data: [WebMultipartProtocol],
        parameters: WebParams?,
        headers: WebHeaders?
    ) {
        self.urlString = urlString
        self.data = data
        self.parameters = parameters
        self.headers = headers
    }
}

public protocol WebMultipartProtocol {
    func appendToMultipartData(formData: MLMultipartFormData)
}

public protocol MLMultipartFormData {
    func appendPartWithFileData(
        _ data: Data,
        name: String,
        fileName: String,
        mimeType: String)
}

public struct WebMultipartData: WebMultipartProtocol {

    public var data: Data?
    public var name: String
    public var fileName: String
    public var mimeType: String

    public init(
        data: Data?,
        name: String,
        fileName: String,
        mimeType: String
    ) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
    
    public func appendToMultipartData(formData: MLMultipartFormData) {
        formData.appendPartWithFileData(
            data ?? Data(),
            name: name,
            fileName: fileName,
            mimeType: mimeType)
    }
}
