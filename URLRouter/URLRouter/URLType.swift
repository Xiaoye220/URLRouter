//
//  URLType.swift
//  URLRouter
//
//  Created by YZF on 29/11/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import Foundation


public protocol URLType {
    var urlValue: URL? { get }
    var urlStringValue: String { get }
    
    var queryParameters: [String: String] { get }
}

extension URLType {
    
    public var queryParameters: [String: String] {
        var parameters: [String: String] = [:]
        let queryItems = URLComponents(string: self.urlStringValue)?.queryItems ?? []
        queryItems.forEach { parameters[$0.name] = $0.value ?? String() }
        return parameters
    }
}

extension String: URLType {
    
    public var urlValue: URL? {
        if let url = URL(string: self) {
            return url
        }
        var set = CharacterSet()
        set.formUnion(.urlHostAllowed)
        set.formUnion(.urlPathAllowed)
        set.formUnion(.urlQueryAllowed)
        set.formUnion(.urlFragmentAllowed)
        return self.addingPercentEncoding(withAllowedCharacters: set).flatMap { URL(string: $0) }
    }
    
    public var urlStringValue: String {
        return self
    }
    
}



extension URL: URLType {
    public var urlValue: URL? {
        return self
    }
    
    public var urlStringValue: String {
        return self.absoluteString
    }
}
