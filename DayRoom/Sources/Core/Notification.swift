//
//  Notification.swift
//  DayRoom
//
//  Created by 한상진 on 2023/07/01.
//

import UIKit
import XCTestDynamicOverlay
import ComposableArchitecture

enum DidEnterBackgroundKey: DependencyKey {
    static let liveValue: @Sendable () async -> AsyncStream<Void> = {
        await AsyncStream(
            NotificationCenter.default
                .notifications(named: UIApplication.didEnterBackgroundNotification)
                .map{ _ in }
        )
    }
    static let testValue: @Sendable () async -> AsyncStream<Void> = unimplemented(
        #"@Dependency(\.DidEnterBackground)"#, placeholder: .finished
    )
}

enum WillEnterForegroundKey: DependencyKey {
    static let liveValue: @Sendable () async -> AsyncStream<Void> = {
        await AsyncStream(
            NotificationCenter.default
                .notifications(named: UIApplication.willEnterForegroundNotification)
                .map{ _ in }
        )
    }
    static let testValue: @Sendable () async -> AsyncStream<Void> = unimplemented(
        #"@Dependency(\.WillEnterForeground)"#, placeholder: .finished
    )
}

enum WillResignActiveKey: DependencyKey {
    static let liveValue: @Sendable () async -> AsyncStream<Void> = {
        await AsyncStream(
            NotificationCenter.default
                .notifications(named: UIApplication.willResignActiveNotification)
                .map{ _ in }
        )
    }
    static let testValue: @Sendable () async -> AsyncStream<Void> = unimplemented(
        #"@Dependency(\.WillResignActive)"#, placeholder: .finished
    )
}

enum DidBecomeActiveKey: DependencyKey {
    static let liveValue: @Sendable () async -> AsyncStream<Void> = {
        await AsyncStream(
            NotificationCenter.default
                .notifications(named: UIApplication.didBecomeActiveNotification)
                .map{ _ in }
        )
    }
    static let testValue: @Sendable () async -> AsyncStream<Void> = unimplemented(
        #"@Dependency(\.DidBecomeActive)"#, placeholder: .finished
    )
}

extension DependencyValues {
    var didEnterBackgroundNotification: @Sendable () async -> AsyncStream<Void> {
        get { self[DidEnterBackgroundKey.self] }
        set { self[DidEnterBackgroundKey.self] = newValue }
    }
}

extension DependencyValues {
    var willEnterForegroundNotification: @Sendable () async -> AsyncStream<Void> {
        get { self[WillEnterForegroundKey.self] }
        set { self[WillEnterForegroundKey.self] = newValue }
    }
}

extension DependencyValues {
    var willResignActiveNotification: @Sendable () async -> AsyncStream<Void> {
        get { self[WillResignActiveKey.self] }
        set { self[WillResignActiveKey.self] = newValue }
    }
}

extension DependencyValues {
    var didBecomeActiveNotification: @Sendable () async -> AsyncStream<Void> {
        get { self[DidBecomeActiveKey.self] }
        set { self[DidBecomeActiveKey.self] = newValue }
    }
}
