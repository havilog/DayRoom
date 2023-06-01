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
    
    public var fontColor: Color {
        switch self {
        case .lucky: return .green
        case .happy: return .yellow
        case .soso: return .white
        case .angry: return .red
        case .sad: return .blue
        }
    }
    
    public var backgroundColor: Color {
        switch self {
        case .lucky: return .green
        case .happy: return .yellow
        case .soso: return .white
        case .angry: return .red
        case .sad: return .blue
        }
    }
}
