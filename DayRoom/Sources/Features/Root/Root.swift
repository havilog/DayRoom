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
    
    struct State: Equatable, Sendable {
        var destination: Destination.State = .splash
    }
    
    struct Destination: Reducer {
        enum State: Equatable {
            case splash
            case nickname(Nickname.State)
            case password(Password.State)
            case feed(Feed.State)
        }
        enum Action: Equatable {
            case nickname(Nickname.Action)
            case password(Password.Action)
            case feed(Feed.Action)
        }
        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.nickname, action: /Action.nickname) {
                Nickname()
            }
            Scope(state: /State.password, action: /Action.password) {
                Password()
            }
            Scope(state: /State.feed, action: /Action.feed) {
                Feed()
            }
        }
    }
    
    // MARK: Action
    
    enum Action: Equatable, Sendable {
        case onFirstAppear
        case splashCompleted
        case onboardingCompleted
        
        case destination(Destination.Action)
    }
    
    // MARK: Dependency
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.preferences) private var preferences
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Scope(state: \State.destination, action: /Action.destination) { 
            Destination()
        }
        
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onFirstAppear:
            preferences.onboardingFinished = false
            return .task { 
                try await self.clock.sleep(for: .seconds(1))
                return .splashCompleted
            }
            .animation()
            
        case .splashCompleted:
            guard preferences.onboardingFinished else { 
                state.destination = .nickname(.init()) 
                return .none
            }
            
            if let _ = preferences.password {
                state.destination = .password(.init())
            } else {
                state.destination = .feed(.init())
            }
            
            return .none
            
        case .onboardingCompleted:
            if let _ = preferences.password {
                state.destination = .password(.init())
            } else {
                state.destination = .feed(.init())
            }
            return .none
            
        case let .destination(.nickname(.delegate(action))):
            switch action {
            case .onboardingFinished:
                preferences.onboardingFinished = true
                return .task { 
                    try await self.clock.sleep(for: .seconds(0.1))
                    return .onboardingCompleted
                }
                .animation()
            }          
            
        case .destination:
            return .none
        }
    }
}
