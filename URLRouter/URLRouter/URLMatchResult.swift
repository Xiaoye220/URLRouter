//
//  URLMatchResult.swift
//  URLRouter
//
//  Created by YZF on 30/11/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import Foundation


/// the result of
///
///     match(_ url: URLType, from registeredURLs: [URLType])  -> URLMatchResult
///
/// - success: match succeeds
/// - fail: match fails
public enum URLMatchResult {
    case success(registeredURL: URLType, parameters: [String: String])
    case fail
}

extension URLMatchResult {
    
    var registeredURL: URLType? {
        switch self {
        case let .success(registeredURL, _):
            return registeredURL
        case .fail:
            return nil
        }
    }
    
    var parameters: [String: String] {
        switch self {
        case let .success(_, parameters):
            return parameters
        case .fail:
            return [:]
        }
    }
}


