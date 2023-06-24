//
//  Font+Custom.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import SwiftUI

public protocol FontLineHeightConfigurable {
    var font: UIFont { get }
    var lineHeight: CGFloat { get }
}

public enum Pretendard: FontLineHeightConfigurable {
    case display1
    case heading1
    case heading2
    case heading3
    case heading4
    case body1
    case body2
    case body3
    case body4
    case body5
    case caption
}

public extension Pretendard {
    var font: UIFont {
        switch self {
        case .display1: return .init(name: "Pretendard-Medium", size: 30)!
        case .heading1: return .init(name: "Pretendard-Medium", size: 24)!
        case .heading2: return .init(name: "Pretendard-Medium", size: 20)!
        case .heading3: return .init(name: "Pretendard-SemiBold", size: 18)!
        case .heading4: return .init(name: "Pretendard-Regular", size: 18)!
        case .body1: return .init(name: "Pretendard-SemiBold", size: 16)!
        case .body2: return .init(name: "Pretendard-Regular", size: 16)!
        case .body3: return .init(name: "Pretendard-ExtraLight", size: 16)!
        case .body4: return .init(name: "Pretendard-SemiBold", size: 14)!
        case .body5: return .init(name: "Pretendard-Regular", size: 14)!
        case .caption: return .init(name: "Pretendard-Regular", size: 12)!
        }
    }
    var lineHeight: CGFloat {
        switch self {
        case .display1: return 42
        case .heading1: return 36
        case .heading2: return 32
        case .heading3: return 30
        case .heading4: return 30
        case .body1: return 28
        case .body2: return 28
        case .body3: return 28
        case .body4: return 24
        case .body5: return 24
        case .caption: return 22
        }
    }
}

public enum Garamond: FontLineHeightConfigurable {
    case hero
    case heading1
    case heading2
    case heading3
    case heading4
    case body1
    case body2
}

public extension Garamond {
    var font: UIFont {
        switch self {
        case .hero: return .init(name: "EBGaramond-Regular", size: 64)!
        case .heading1: return .init(name: "EBGaramond-Regular", size: 32)!
        case .heading2: return .init(name: "EBGaramond-Medium", size: 24)!
        case .heading3: return .init(name: "EBGaramond-SemiBold", size: 22)!
        case .heading4: return .init(name: "EBGaramond-Regular", size: 20)!
        case .body1: return .init(name: "EBGaramond-Regular", size: 18)!
        case .body2: return .init(name: "EBGaramond-Regular", size: 16)!
        }
    } 
    var lineHeight: CGFloat {
        switch self {
        case .hero: return 76
        case .heading1: return 40
        case .heading2: return 32
        case .heading3: return 30
        case .heading4: return 28
        case .body1: return 26
        case .body2: return 24
        }
    }
}

import SwiftUI

struct FontWithLineHeight: ViewModifier {
    let fontLineHeight: FontLineHeightConfigurable
    
    func body(content: Content) -> some View {
        content
            .font(Font(fontLineHeight.font))
            .lineSpacing(fontLineHeight.lineHeight - fontLineHeight.font.lineHeight)
            .padding(.vertical, (fontLineHeight.lineHeight - fontLineHeight.font.lineHeight) / 2)
    }
}

extension View {
    func font(pretendard: Pretendard) -> some View {
        return modifier(FontWithLineHeight(fontLineHeight: pretendard as FontLineHeightConfigurable))
    }
    
    func font(garamond: Garamond) -> some View {
        modifier(FontWithLineHeight(fontLineHeight: garamond as FontLineHeightConfigurable))
    }
}
