//
//  Home.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/14.
//

import ComposableArchitecture

struct Main: Reducer {
    
    // MARK: State
    
    struct State: Equatable {
        var feed: Feed.State = .init()
        var path: StackState<Path.State> = .init()
    }
    
    // MARK: Action
    
    enum Action: Equatable {
        case feed(Feed.Action)
        case path(StackAction<Path.State, Path.Action>)
    }
    
    // MARK: Path
    
    struct Path: Reducer {
        enum State: Hashable {
            case setting(Setting.State)
        }
        
        enum Action: Equatable {
            case setting(Setting.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.setting, action: /Action.setting) { 
                Setting()
            }
        }
    }
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Scope(state: \.feed, action: /Action.feed) { 
            Feed()
        }
        
        Reduce(core)
            .forEach(\.path, action: /Action.path) { 
                Path()
            }
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .feed(.delegate(action)):
            switch action {
            case .settingButtonTapped:
                state.path.append(.setting(.init()))
                return .none    
            }
            
        case let .feed(action):
            print(action)
            return .none
            
        case .path:
            return .none
        }
    }
}
