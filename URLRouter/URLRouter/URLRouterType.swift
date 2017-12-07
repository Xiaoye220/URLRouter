//
//  URLRouterType.swift
//  URLRouter
//
//  Created by YZF on 29/11/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import UIKit

internal protocol URLRouterType: class {
    
    var routes: [String: URLHandle] { get set }
    var objectRoutes: [String: URLObjectHandle] { get set }
    
    var urlMatcher: URLMatcher { get set }
    
    func register(_ url: URLType, handle: @escaping URLHandle)
    
    func registerObject(_ url: URLType, object: @escaping URLObjectHandle)
    
    @discardableResult
    func open(_ url: URLType, context: Any?) -> Bool
    
    func object<O>(for url: URLType, context: Any?) -> O?
    
}






