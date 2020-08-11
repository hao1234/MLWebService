//
//  JSONError.swift
//  MLWebService
//
//  Created by Nguyen Vu Hao on 8/11/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import Foundation

open class JSONError {

    public let code: String
    public let userDefinedMessageObject: [String: Any]?
    public let context: [String: Any]?

    public init(code: String,
                userDefinedMessageObject object: [String: Any]? = nil,
                context: [String: Any]? = nil) {
        self.code = code
        self.userDefinedMessageObject = object
        self.context = context
    }
}
