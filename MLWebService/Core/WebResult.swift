//
//  WebResult.swift
//  MLWebService
//
//  Created by Nguyen Vu Hao on 8/12/20.
//  Copyright © 2020 HaoNV. All rights reserved.
//

import Foundation

public enum Result<T> {

    case success(T)
    case failure(Error)

    public var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }

    public var isFailure: Bool {
        return !isSuccess
    }

    public var value: T? {
        switch self {
        case .success(let value): return value
        case .failure: return nil
        }
    }

    public var error: Error? {
        switch self {
        case .success: return nil
        case .failure(let error): return error
        }
    }
    
}
