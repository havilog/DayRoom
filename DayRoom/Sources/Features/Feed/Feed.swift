//
//  FeedFeature.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import ComposableArchitecture

struct Feed: Reducer {
    
    // MARK: State
    
    struct State: Hashable {
        
    }
    
    // MARK: Action
    
    enum Action: Equatable {
        case settingButtonTapped
        case createButtonTapped
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case settingButtonTapped 
        }
    }
    
    // MARK: Dependency
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .settingButtonTapped:
            return .send(.delegate(.settingButtonTapped))
            
        case .createButtonTapped:
            return .none
            
        case .delegate:
            return .none
        }
    }
}

