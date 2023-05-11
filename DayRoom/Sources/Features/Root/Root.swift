//
//  Root.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/08.
//

import Foundation
import ComposableArchitecture

struct Root: Reducer {
    
    // MARK: State
    
    enum State: Equatable, Sendable {
        case splash
        case nickname(Nickname.State)
        case password(Password.State)
        case feed(Feed.State)
    }
    
    // MARK: Action
    
    enum Action: Equatable, Sendable {
        case onAppear
        case splashCompleted
        
        case nickname(Nickname.Action)
        case password(Password.Action)
        case feed(Feed.Action)
    }
    
    // MARK: Dependency
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.preferences) private var preferences
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Reduce(core)
            .ifCaseLet(/State.nickname, action: /Action.nickname) {
                Nickname()
            }
            .ifCaseLet(/State.password, action: /Action.password) {
                Password()
            }
            .ifCaseLet(/State.feed, action: /Action.feed) {
                Feed()
            }
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onAppear:
            return .task { 
                try await self.clock.sleep(for: .seconds(1))
                return .splashCompleted
            }
            .animation()
            
        case .splashCompleted:
            guard preferences.onboardingFinished else { 
                state = .nickname(.init()) 
                return .none
            }
            
            if let _ = preferences.password {
                state = .password(.init())
            } else {
                state = .feed(.init())
            }
            
            return .none
            
        case .nickname:
            return .none
            
        case .password:
            return .none
            
        case .feed:
            return .none
        }
    }
}
