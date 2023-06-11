//
//  DiaryMood.swift
//  DayRoom
//
//  Created by 한상진 on 2023/06/01.
//

import SwiftUI
import Foundation

public enum DiaryMood: Identifiable, Equatable, CaseIterable {
    case lucky
    case happy
    case soso
    case angry
    case sad
    
    public var id: Self { return self }
    
    public var title: String {
        switch self {
        case .lucky: return "Lucky"
        case .happy: return "Happy"
        case .soso: return "Soso"
        case .angry: return "Angry"
        case .sad: return "Sad"
        }
    }
    
    public var imageName: String {
        switch self {
        case .lucky: return "img_lucky"
        case .happy: return "img_happy"
        case .soso: return "img_soso"
        case .angry: return "img_angry"
        case .sad: return "img_sad"
        }
    }
    
    public var backgroundOpacity: CGFloat {
        switch self {
        case .lucky: return 0.2
        case .happy: return 0.25
        case .soso: return 0.4
        case .angry: return 0.2
        case .sad: return 0.35
        }
    }
    
    public var foregroundColor: Color {
        switch self {
        case .lucky: return .mood_lucky
        case .happy: return .mood_happy
        case .soso: return .mood_soso
        case .angry: return .mood_angry
        case .sad: return .mood_sad
        }
    }
}
