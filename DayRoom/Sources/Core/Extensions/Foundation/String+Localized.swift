//
//  String+Localized.swift
//  DayRoom
//
//  Created by 한상진 on 2023/07/16.
//

import Foundation

public extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", value: self, comment: "")
    }
}
