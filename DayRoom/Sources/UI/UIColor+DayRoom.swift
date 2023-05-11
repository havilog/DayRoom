//
//  UIColor+DayRoom.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import UIKit

// MARK: GrayScale

public extension UIColor {
    static let day_white: UIColor = hex("ffffff")
    static let grey05: UIColor = hex("F8F8F7")
    static let grey10: UIColor = hex("F0F0EF")
    static let grey20: UIColor = hex("E5E4E4")
    static let grey30: UIColor = hex("C4C3C2")
    static let grey40: UIColor = hex("ADABAB")
    static let grey50: UIColor = hex("949291")
    static let grey60: UIColor = hex("7D7B7A")
    static let grey70: UIColor = hex("615F5D")
    static let grey80: UIColor = hex("474442")
    static let grey90: UIColor = hex("2B2928")
    static let day_black: UIColor = hex("151414")
}

// MARK: Brand Color

public extension UIColor {
    static let day_green: UIColor = hex("40805F")
    static let day_green_dark: UIColor = hex("285B3C")
    static let day_green_light: UIColor = hex("A7DB95")
    static let day_green_background: UIColor = hex("E6F0E7")
    static let day_brown: UIColor = hex("A37F5F")
    static let day_brown_light: UIColor = hex("E5D9CF")
    static let day_brown_background: UIColor = hex("F7F5F2")
}

// MARK: System Color

public extension UIColor {
    static let info: UIColor = hex("55B4FF")
    static let warning: UIColor = hex("F0B13C")
    static let error: UIColor = hex("F56C51")
    static let success: UIColor = hex("63CC5E")
    static let info_dark: UIColor = hex("2C8AD3")
    static let warning_dark: UIColor = hex("DD8A1D")
    static let error_dark: UIColor = hex("CC3E21")
    static let success_dark: UIColor = hex("2B9926")
}

// MARK: Transparent gray 05

public extension UIColor {
    static let transparent_gray90: UIColor = hex("F8F8F7", alpha: 0.9)
    static let transparent_gray80: UIColor = hex("F8F8F7", alpha: 0.8)
    static let transparent_gray70: UIColor = hex("F8F8F7", alpha: 0.7)
    static let transparent_gray60: UIColor = hex("F8F8F7", alpha: 0.6)
    static let transparent_gray50: UIColor = hex("F8F8F7", alpha: 0.5)
    static let transparent_gray40: UIColor = hex("F8F8F7", alpha: 0.4)
    static let transparent_gray30: UIColor = hex("F8F8F7", alpha: 0.3)
    static let transparent_gray20: UIColor = hex("F8F8F7", alpha: 0.2)
    static let transparent_gray10: UIColor = hex("F8F8F7", alpha: 0.1)
}

// MARK: Transparent black

public extension UIColor {
    static let transparent_black90: UIColor = hex("151414", alpha: 0.9)
    static let transparent_black80: UIColor = hex("151414", alpha: 0.8)
    static let transparent_black70: UIColor = hex("151414", alpha: 0.7)
    static let transparent_black60: UIColor = hex("151414", alpha: 0.6)
    static let transparent_black50: UIColor = hex("151414", alpha: 0.5)
    static let transparent_black40: UIColor = hex("151414", alpha: 0.4)
    static let transparent_black30: UIColor = hex("151414", alpha: 0.3)
    static let transparent_black20: UIColor = hex("151414", alpha: 0.2)
    static let transparent_black10: UIColor = hex("151414", alpha: 0.1)
}

// MARK: Mood Color

public extension UIColor {
    static let happy: UIColor = hex("FABF96")
    static let happy_light: UIColor = hex("FFDDBD")
    
    static let proud: UIColor = hex("FFC1B8")
    static let proud_light: UIColor = hex("FCE8E3")
    
    static let excited: UIColor = hex("F7D0DA")
    static let excited_light: UIColor = hex("FAE1F1")
    
    static let joyful: UIColor = hex("F5DA9D")
    static let joyful_light: UIColor = hex("FAE8BE")
    
    static let peaceful: UIColor = hex("D0DCA3")
    static let peaceful_light: UIColor = hex("E1E8C9")
    
    static let thankful: UIColor = hex("C1E3C3")
    static let thankful_light: UIColor = hex("D5EBDE")
    
    static let soso: UIColor = hex("D6CBC3")
    static let soso_light: UIColor = hex("F0E7E0")
    
    static let worried: UIColor = hex("CBD0D4")
    static let worried_light: UIColor = hex("DCE0E4")
    
    static let tired: UIColor = hex("C1D6D0")
    static let tired_light: UIColor = hex("D8E6E8")
    
    static let diappointed: UIColor = hex("D6B096")
    static let diappointed_light: UIColor = hex("F2DFCE")
    
    static let annoyed: UIColor = hex("DEAFB7")
    static let annoyed_light: UIColor = hex("EEDDE3")
    
    static let angry: UIColor = hex("EBA298")
    static let angry_light: UIColor = hex("FADBD9")
    
    static let painful: UIColor = hex("CABFE3")
    static let painful_light: UIColor = hex("EAE3F7")
    
    static let depressed: UIColor = hex("ADB9DE")
    static let depressed_light: UIColor = hex("E1E6F5")
}

// MARK: Semantic Color

public extension UIColor {
    static var primary: UIColor = UIColor { $0.userInterfaceStyle == .dark ? hex("40805F") : hex("42CC79") }
    static var background: UIColor = UIColor { $0.userInterfaceStyle == .dark ? hex("F8F8F7") : hex("151414") }
    static var elevated: UIColor = UIColor { $0.userInterfaceStyle == .dark ? hex("F0F0EF") : hex("2B2928") }
    static var divider: UIColor = UIColor { $0.userInterfaceStyle == .dark ? hex("E5E4E4") : hex("474442") }
    static var text_primary: UIColor = UIColor { $0.userInterfaceStyle == .dark ? hex("474442") : hex("F0F0EF") }
    static var text_secondary: UIColor = UIColor { $0.userInterfaceStyle == .dark ? hex("7D7B7A") : hex("C4C3C2") }
    static var text_diabled: UIColor = UIColor { $0.userInterfaceStyle == .dark ? hex("C4C3C2") : hex("615F5D") }
}
