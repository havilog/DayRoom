//
//  Color+DayRoom.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import UIKit
import SwiftUI

// MARK: GrayScale

public extension Color {
    static let day_white: Color = .init(uiColor: .init(hex: "ffffff"))
    static let grey05: Color = .init(uiColor: .init(hex: "F8F8F7"))
    static let grey10: Color = .init(uiColor: .init(hex: "F0F0EF"))
    static let grey20: Color = .init(uiColor: .init(hex: "E5E4E4"))
    static let grey30: Color = .init(uiColor: .init(hex: "C4C3C2"))
    static let grey40: Color = .init(uiColor: .init(hex: "ADABAB"))
    static let grey50: Color = .init(uiColor: .init(hex: "949291"))
    static let grey60: Color = .init(uiColor: .init(hex: "7D7B7A"))
    static let grey70: Color = .init(uiColor: .init(hex: "615F5D"))
    static let grey80: Color = .init(uiColor: .init(hex: "474442"))
    static let grey90: Color = .init(uiColor: .init(hex: "2B2928"))
    static let day_black: Color = .init(uiColor: .init(hex: "151414"))
}

// MARK: Brand Color

public extension Color {
    static let day_green: Color = .init(uiColor: .init(hex: "83B065"))
    static let day_green_dark: Color = .init(uiColor: .init(hex: "5C7C45"))
    static let day_green_light: Color = .init(uiColor: .init(hex: "A7DB95"))
    static let day_green_background: Color = .init(uiColor: .init(hex: "E6F0E7"))
    static let day_brown: Color = .init(uiColor: .init(hex: "A37F5F"))
    static let day_brown_light: Color = .init(uiColor: .init(hex: "E5D9CF"))
    static let day_brown_background: Color = .init(uiColor: .init(hex: "F7F5F2"))
}

// MARK: System Color

public extension Color {
    static let info: Color = .init(uiColor: .init(hex: "55B4FF"))
    static let warning: Color = .init(uiColor: .init(hex: "F0B13C"))
    static let error: Color = .init(uiColor: .init(hex: "F56C51"))
    static let success: Color = .init(uiColor: .init(hex: "63CC5E"))
    static let info_dark: Color = .init(uiColor: .init(hex: "2C8AD3"))
    static let warning_dark: Color = .init(uiColor: .init(hex: "DD8A1D"))
    static let error_dark: Color = .init(uiColor: .init(hex: "CC3E21"))
    static let success_dark: Color = .init(uiColor: .init(hex: "2B9926"))
}

// MARK: Transparent gray 05

public extension Color {
    static let transparent_gray90: Color = .init(uiColor: .init(hex: "F8F8F7", alpha: 0.9))
    static let transparent_gray80: Color = .init(uiColor: .init(hex: "F8F8F7", alpha: 0.8))
    static let transparent_gray70: Color = .init(uiColor: .init(hex: "F8F8F7", alpha: 0.7))
    static let transparent_gray60: Color = .init(uiColor: .init(hex: "F8F8F7", alpha: 0.6))
    static let transparent_gray50: Color = .init(uiColor: .init(hex: "F8F8F7", alpha: 0.5))
    static let transparent_gray40: Color = .init(uiColor: .init(hex: "F8F8F7", alpha: 0.4))
    static let transparent_gray30: Color = .init(uiColor: .init(hex: "F8F8F7", alpha: 0.3))
    static let transparent_gray20: Color = .init(uiColor: .init(hex: "F8F8F7", alpha: 0.2))
    static let transparent_gray10: Color = .init(uiColor: .init(hex: "F8F8F7", alpha: 0.1))
}

// MARK: Transparent black

public extension Color {
    static let transparent_black90: Color = .init(uiColor: .init(hex: "151414", alpha: 0.9))
    static let transparent_black80: Color = .init(uiColor: .init(hex: "151414", alpha: 0.8))
    static let transparent_black70: Color = .init(uiColor: .init(hex: "151414", alpha: 0.7))
    static let transparent_black60: Color = .init(uiColor: .init(hex: "151414", alpha: 0.6))
    static let transparent_black50: Color = .init(uiColor: .init(hex: "151414", alpha: 0.5))
    static let transparent_black40: Color = .init(uiColor: .init(hex: "151414", alpha: 0.4))
    static let transparent_black30: Color = .init(uiColor: .init(hex: "151414", alpha: 0.3))
    static let transparent_black20: Color = .init(uiColor: .init(hex: "151414", alpha: 0.2))
    static let transparent_black10: Color = .init(uiColor: .init(hex: "151414", alpha: 0.1))
}

// MARK: Mood Color

public extension Color {
    static let happy: Color = .init(uiColor: .init(hex: "FABF96"))
    static let happy_light: Color = .init(uiColor: .init(hex: "FFDDBD"))
    static let proud: Color = .init(uiColor: .init(hex: "FFC1B8"))
    static let proud_light: Color = .init(uiColor: .init(hex: "FCE8E3"))
    static let excited: Color = .init(uiColor: .init(hex: "F7D0DA"))
    static let excited_light: Color = .init(uiColor: .init(hex: "FAE1F1"))
    static let joyful: Color = .init(uiColor: .init(hex: "F5DA9D"))
    static let joyful_light: Color = .init(uiColor: .init(hex: "FAE8BE"))
    static let peaceful: Color = .init(uiColor: .init(hex: "D0DCA3"))
    static let peaceful_light: Color = .init(uiColor: .init(hex: "E1E8C9"))
    static let thankful: Color = .init(uiColor: .init(hex: "C1E3C3"))
    static let thankful_light: Color = .init(uiColor: .init(hex: "D5EBDE"))
    static let soso: Color = .init(uiColor: .init(hex: "D6CBC3"))
    static let soso_light: Color = .init(uiColor: .init(hex: "F0E7E0"))
    static let worried: Color = .init(uiColor: .init(hex: "CBD0D4"))
    static let worried_light: Color = .init(uiColor: .init(hex: "DCE0E4"))
    static let tired: Color = .init(uiColor: .init(hex: "C1D6D0"))
    static let tired_light: Color = .init(uiColor: .init(hex: "D8E6E8"))
    static let diappointed: Color = .init(uiColor: .init(hex: "D6B096"))
    static let diappointed_light: Color = .init(uiColor: .init(hex: "F2DFCE"))
    static let annoyed: Color = .init(uiColor: .init(hex: "DEAFB7"))
    static let annoyed_light: Color = .init(uiColor: .init(hex: "EEDDE3"))
    static let angry: Color = .init(uiColor: .init(hex: "EBA298"))
    static let angry_light: Color = .init(uiColor: .init(hex: "FADBD9"))
    static let painful: Color = .init(uiColor: .init(hex: "CABFE3"))
    static let painful_light: Color = .init(uiColor: .init(hex: "EAE3F7"))
    static let depressed: Color = .init(uiColor: .init(hex: "ADB9DE"))
    static let depressed_light: Color = .init(uiColor: .init(hex: "E1E6F5"))
}

// MARK: Semantic Color

public extension Color {
    static var day_primary: Color = Color(uiColor: UIColor { $0.userInterfaceStyle == .light ? .init(hex: "40805F") : .init(hex: "42CC79") }) 
    static var day_background: Color = Color(uiColor: UIColor { $0.userInterfaceStyle == .light ? .init(hex: "F8F8F7") : .init(hex: "151414") })
    static var elevated: Color = Color(uiColor: UIColor { $0.userInterfaceStyle == .light ? .init(hex: "F0F0EF") : .init(hex: "2B2928") })
    static var divider: Color = Color(uiColor: UIColor { $0.userInterfaceStyle == .light ? .init(hex: "E5E4E4") : .init(hex: "474442") })
    static var text_primary: Color = Color(uiColor: UIColor { $0.userInterfaceStyle == .light ? .init(hex: "4D4A48") : .init(hex: "F0F0EF") })
    static var text_secondary: Color = Color(uiColor: UIColor { $0.userInterfaceStyle == .light ? .init(hex: "7D7B7A") : .init(hex: "C4C3C2") })
    static var text_disabled: Color = Color(uiColor: UIColor { $0.userInterfaceStyle == .light ? .init(hex: "C4C3C2") : .init(hex: "615F5D") })
}

// MARK: Mood

public extension Color {
    static let mood_lucky: Color = .init(uiColor: .init(hex: "618C5A"))
    static let mood_happy: Color = .init(uiColor: .init(hex: "DF9339"))
    static let mood_soso: Color = .init(uiColor: .init(hex: "9D816E"))
    static let mood_angry: Color = .init(uiColor: .init(hex: "D66A52"))
    static let mood_sad: Color = .init(uiColor: .init(hex: "7A79AA"))
}
