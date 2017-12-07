//
//  URLRouter.swift
//  URLRouter
//
//  Created by YZF on 29/11/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import Foundation
import UIKit

public typealias URLHandle = (_ url: String, _ parameters: [String: String], _ context: Any?) -> Void
public typealias URLObjectHandle = (_ url: String, _ parameters: [String: String], _ context: Any?) -> Any?

open class URLRouter: URLRouterType {
    
    init() { }
    
    public static let shared = URLRouter()
    
    internal var routes: [String: URLHandle] = [:]
    internal var objectRoutes: [String: URLObjectHandle] = [:]
    
    public var urlMatcher: URLMatcher = .`default`
    
    public func register(_ url: URLType, handle: @escaping URLHandle) {
        self.routes[url.urlStringValue] = handle
    }
    
    public func registerObject(_ url: URLType, object: @escaping URLObjectHandle) {
        self.objectRoutes[url.urlStringValue] = object
    }
    
    @discardableResult
    public func open(_ url: URLType, context: Any? = nil) -> Bool {
        let matchResult = urlMatcher.matcher.match(url, from: Array(routes.keys))
        if case let .success(registeredURL, parameters) = matchResult {
            let registeredURLStr = registeredURL.urlStringValue
            if let handle = routes[registeredURLStr] {
                handle(url.urlStringValue, parameters, context)
                return true
            }
        }
        return false
    }
    
    public func object<O>(for url: URLType, context: Any? = nil) -> O? {
        let matchResult = urlMatcher.matcher.match(url, from: Array(objectRoutes.keys))
        if case let .success(registeredURL, parameters) = matchResult {
            let registeredURLStr = registeredURL.urlStringValue
            if let handle = objectRoutes[registeredURLStr] {
                if let obj = handle(url.urlStringValue, parameters, context) as? O { return obj }
            }
        }
        return nil
    }
    
}
