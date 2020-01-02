//
//  DateExtension.swift
//  Tolocam
//
//  Created by wyx on 2019/3/4.
//  Copyright © 2019年 leo. All rights reserved.
//

import Foundation

extension Date {
    func getFormatString() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateStr = df.string(from: self)
        return dateStr
    }
    
    static func getDateFrom(timestamp: Int) -> Date {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp/1000))
        return date
    }
}
