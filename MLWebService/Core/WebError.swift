//
//  WebError.swift
//  MLWebService
//
//  Created by Nguyen Vu Hao on 8/11/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import Foundation

public enum WebError: Error {

    case invalidResponse(String)
    case httpStatus(status: Int, msg: String)
    case httpXMLStatus(status: Int, xml: String?)

    case serverJSONError(JSONError)

    case networkError(Error)

    case unknownError(Error)
    case unknown(String)

    public var code: String? {
        switch self {
        case .httpStatus(let status, _):
            return "\(status)"
        case .serverJSONError(let jsonError):
            return jsonError.code
        case .unknown(let error):
            return error
        case .invalidResponse(let errror):
            return errror
        default:
            return nil
        }
    }
}

