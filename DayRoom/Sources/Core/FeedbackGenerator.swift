//
//  FeedbackGenerator.swift
//  DayRoom
//
//  Created by 한상진 on 2023/06/24.
//

import UIKit
import XCTestDynamicOverlay
import ComposableArchitecture

@MainActor
public struct FeedbackGenerator {
    var notification: (UINotificationFeedbackGenerator.FeedbackType) -> Void
    var impact: (UIImpactFeedbackGenerator.FeedbackStyle) -> Void
}

extension FeedbackGenerator: DependencyKey {
    public static var liveValue: FeedbackGenerator = .init(
        notification: { @MainActor feedbackType in
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(feedbackType)
        }, 
        impact: { @MainActor style in
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    )
    public static var testValue: FeedbackGenerator = unimplemented()
}

extension DependencyValues {
    var feedbackGenerator: FeedbackGenerator {
        get { self[FeedbackGenerator.self] }
        set { self[FeedbackGenerator.self] = newValue }
    }
}

