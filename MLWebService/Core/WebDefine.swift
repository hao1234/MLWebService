//
//  WebDefine.swift
//  MLWebService
//
//  Created by Nguyen Vu Hao on 8/11/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import Foundation
import SwiftyJSON

public typealias WebParams = [String: Any]
public typealias WebHeaders = [String: String]

public typealias WebResultBlock = (Results) -> ()
public typealias WebProgressBlock = (Float) -> ()

public enum WebMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public enum WebEncoding: String {
    case url = "application/x-www-form-urlencoded; charset=UTF-8"
    case json = "application/json"
    case xml = "application/xml; text/xml"
}

public enum WebResponse {
    case json([String: Any])
    case xml(Data)
}

public struct Results {
    public var data: JSON?
    public var response: Response?
    public var error: Error?
    
    public init(withData data: Data?, response: Response?, error: Error?) {
        if let dataJson = data {
            self.data = try! JSON(data: dataJson)
        }
        
        self.response = response
        self.error = error
    }
    
    public init(withError error: Error) {
        self.error = error
    }
}

public struct Response {
    var response: URLResponse?
    var httpStatusCode: Int = 0
    
    public init(fromURLResponse response: URLResponse?) {
        guard let response = response else { return }
        self.response = response
        httpStatusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
