//
//  URLMatcher.swift
//  URLRouter
//
//  Created by YZF on 30/11/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import Foundation


/// DefaultURLMatcher
///
/// matching rule:
///
///     "scheme://user/Tommy"  ->  "scheme://user/<name>"
///     // match succeeds
///     // parameters: ["name": "Tommy"]
///
///     "scheme://user/Tommy/22"  ->  "scheme://user/<name>/<age>"
///     // match succeeds
///     // parameters: ["name": "Tommy", "age": "22"]
///
///     "scheme://user/Tommy?age=22&sex=boy"  ->  "scheme://user/<name>"
///     // match succeeds
///     // parameters: ["name": "Tommy", "age": "22", "sex": "boy"]
///
///     "scheme://user/Tommy?age=22&sex=boy"  ->  "scheme://user/<name>?<age,sex>"
///     // match succeeds
///     //parameters: ["name": "Tommy", "age": "22", "sex": "boy"]
///
///     "scheme://user/Tommy"  ->  "scheme://user/<name>?<age,sex>"
///     // match fails
open class DefaultURLMatcher: URLMatcherType {
    
    public func match(_ url: URLType, from registeredURLs: [URLType]) -> URLMatchResult {
        let registeredURLs = sortedURLs(registeredURLs)
        
        for registeredURL in registeredURLs {
            let result = match(url, with: registeredURL)
            if case .success = result {
                return result
            }
        }
        return .fail
    }
    
    func match(_ url: URLType, with registeredURL: URLType) -> URLMatchResult {
        let urlScheme = url.urlValue?.scheme
        let urlPathComponents = self.stringPathComponents(from: url)
        let urlQueryParameters = url.queryParameters
        
        let registeredURLScheme = registeredURL.urlValue?.scheme
        let registeredURLPathComponents = self.stringPathComponents(from: registeredURL)
        let registeredURLQueryComponents = self.registeredURLQueryComponents(from: registeredURL)
        
        if urlScheme != registeredURLScheme {
            return .fail
        }
        
        if registeredURLPathComponents.last != "<path>" && urlPathComponents.count != registeredURLPathComponents.count {
            return .fail
        }
        
        if !Set(registeredURLQueryComponents).isSubset(of: Set(urlQueryParameters.keys)) {
            return .fail
        }
        
        var parameters: [String: String] = [:]
        
        let pairCount = min(urlPathComponents.count, registeredURLPathComponents.count)
        
        for index in 0 ..< pairCount {
            let urlPathComponent = urlPathComponents[index]
            let registeredURLPathComponent =  registeredURLPathComponents[index]
            if registeredURLPathComponent.hasPrefix("<") && registeredURLPathComponent.hasSuffix(">") {
                let placeholder = registeredURLPathComponent[1, registeredURLPathComponent.count - 2] // "<path>" -> "path"
                if placeholder == "path" {
                    var path = ""
                    for pathIndex in index ..< urlPathComponents.count {
                        path += urlPathComponents[pathIndex]
                        if pathIndex < urlPathComponents.count - 1 {
                            path += "/"
                        }
                    }
                    parameters[placeholder] = path
                } else {
                    parameters[placeholder] = urlPathComponent
                }
            } else {
                // urlPathComponent 不同
                if urlPathComponent != registeredURLPathComponent {
                    return .fail
                }
            }
        }
        
        url.queryParameters.forEach { parameters[$0.key] = $0.value }
        
        return .success(registeredURL: registeredURL, parameters: parameters)
    }
    
    /// Prevent matching confusion
    ///
    ///     url1: "scheme://user/<name>"
    ///     url2: "scheme://<path>"
    ///
    ///     "scheme://user/Tommy" will match url1 first.If the match fails then match url2.
    func sortedURLs(_ urls: [URLType]) -> [URLType] {
        let sorted = urls.sorted { (url1, url2) -> Bool in
            let url1PathComponents = self.stringPathComponents(from: url1)
            let url2PathComponents = self.stringPathComponents(from: url2)
            if let index1 = url1PathComponents.index(of: "<path>") {
                if let index2 = url2PathComponents.index(of: "<path>") {
                    if index1 > index2 {
                        return true
                    }
                }
                return false
            }
            return true
        }
        return sorted
    }
    
    func replaceRegex(_ pattern: String, _ repl: String, _ string: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return string }
        let range = NSMakeRange(0, string.count)
        return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: repl)
    }
    
    func stringPathComponents(from url: URLType) -> [String] {
        return url.urlStringValue.components(separatedBy: "?")[0]
            .components(separatedBy: "/")
            .filter { !$0.isEmpty }
            .filter { !$0.hasSuffix(":") }
    }
    
    func registeredURLQueryComponents(from url: URLType) -> [String] {
        let urlComponents = url.urlStringValue.components(separatedBy: "?")
        if urlComponents.count == 2 {
            let queryStr = urlComponents[1]
            if queryStr.hasPrefix("<") && queryStr.hasSuffix(">") {
                let components = queryStr[1, queryStr.count - 2].components(separatedBy: ",").map { $0.removeHeadAndTailSpace }
                return components
            }
        }
        return []
    }
}
