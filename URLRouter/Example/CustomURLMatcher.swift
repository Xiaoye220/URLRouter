//
//  CustomRouter.swift
//  URLRouter
//
//  Created by YZF on 4/12/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import Foundation

class CustomURLMatcher: URLMatcherType {
    
    /// only match scheme
    ///
    ///     "a://"  -> "a://user/Tommy"
    ///     // match succeeds
    ///
    ///     "b://"  -> "a://user/Tommy"
    ///     // match fails
    func match(_ url: URLType, from registeredURLs: [URLType]) -> URLMatchResult {
        for registeredURL in registeredURLs {
            if url.urlValue?.scheme == registeredURL.urlValue?.scheme {
                return .success(registeredURL: registeredURL, parameters: ["scheme": url.urlValue!.scheme!])
            }
        }
        return .fail
    }
}
