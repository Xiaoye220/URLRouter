//
//  URLMatcherType.swift
//  URLRouter
//
//  Created by YZF on 5/12/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import Foundation


public protocol URLMatcherType {
    func match(_ url: URLType, from registeredURLs: [URLType]) -> URLMatchResult
}

public enum URLMatcher {
    case `default`
    case regex
    case custom(URLMatcherType)
}

extension URLMatcher {
    var matcher: URLMatcherType {
        switch self {
        case .`default`:
            return DefaultURLMatcher()
        case .regex:
            return RegexURLMatcher()
        case let .custom(matcher):
            return matcher
        }
    }
    
}

