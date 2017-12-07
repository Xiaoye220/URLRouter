//
//  String+Extension.swift
//  EmptyDataSet-Swift
//
//  Created by YZF on 29/6/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import Foundation

extension String {
    
    subscript(_ from: Int, _ to: Int) -> String {
        guard to >= from, from >= 0, to <= self.count - 1 else {
            fatalError("index error")
        }
        
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        
        return String(self[startIndex...endIndex])
    }
    
    
    var removeHeadAndTailSpace:String {
        let whitespace = NSCharacterSet.whitespaces
        return self.trimmingCharacters(in: whitespace)
    }
    
}
