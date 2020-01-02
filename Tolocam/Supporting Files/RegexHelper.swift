//
//  RegexHelper.swift
//  Tolocam
//
//  Created by wyx on 2019/4/29.
//  Copyright © 2019年 leo. All rights reserved.
//

import Foundation

public struct RegexHelper {    
    let regex: NSRegularExpression
    
    init(_ pattern: String) throws {
        try regex = NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }
    
    func match(_ input: String) -> Bool {
        let matches = regex.matches(in: input, options: [], range: NSMakeRange(0, input.utf16.count))
        return matches.count > 0
    }
}
