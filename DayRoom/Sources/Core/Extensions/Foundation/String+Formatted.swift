//
//  String+Formatted.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/19.
//

import Foundation

public extension Date {
    var yearMonthDay: String {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "yyyy. MM. dd"
        return formatter.string(from: self)
    }
    
    var day: String {
        return ""
    }
    
    var dayOfWeek: String {
        return ""
    }
}
