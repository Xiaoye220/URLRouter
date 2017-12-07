//
//  RegexURLMatcher.swift
//  URLRouter
//
//  Created by YZF on 5/12/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import Foundation


/// URLMatcher with regular expression
///
/// for example:
///
///     "scheme://user/Tommy?age=22&sex=boy"  ->  "scheme://user/\\w+\\?age=\\d+&sex=\\w+"
///     // match succeeds
///     // parameters: ["age": "22", "sex": "boy"]
///
///     "scheme://user/123"  ->  "scheme://user/\\w+"
///     // match fails
///
/// how to use RegexURLMatcher:
///
///     URLRouter.shared.urlMatcher = .regex
open class RegexURLMatcher: URLMatcherType {
    
    public func match(_ url: URLType, from registeredURLs: [URLType]) -> URLMatchResult {
        for registeredURL in registeredURLs {
            let result = match(url, with: registeredURL)
            if case .success = result {
                return result
            }
        }
        return .fail
    }
    
    func match(_ url: URLType, with registeredURL: URLType) -> URLMatchResult {
        let predicate = NSPredicate(format: "SELF MATCHES %@", registeredURL.urlStringValue)
        if predicate.evaluate(with: url.urlStringValue) {
            return .success(registeredURL: registeredURL, parameters: url.queryParameters)
        }
        return .fail
    }
}
