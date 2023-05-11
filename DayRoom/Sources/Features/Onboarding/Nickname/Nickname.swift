//
//  NicknameFeature.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import ComposableArchitecture

struct Nickname: Reducer {
    
    // MARK: State
    
    struct State: Equatable {
        var path: StackState<Path.State> = .init()
        @BindingState var nickname: String = ""
        @BindingState var focusedField: Field = .nickname
        
        enum Field: String, Hashable {
            case nickname
        }
    }
    
    // MARK: Action
    
    enum Action: Equatable, BindableAction {
        case nextButtonTapped
        
        case binding(BindingAction<State>)
        case path(StackAction<Path.State, Path.Action>)
    }
    
    // MARK: Path
    
    struct Path: Reducer {
        enum State: Hashable {
            case recordGoal(RecordGoal.State)
        }
        
        enum Action: Equatable {
            case recordGoal(RecordGoal.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.recordGoal, action: /Action.recordGoal) { 
                RecordGoal()
            }
        }
    }
    
    // MARK: Dependency
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce(core)
            .forEach(\.path, action: /Action.path) { 
                Path()
            }
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .nextButtonTapped:
            state.path.append(.recordGoal(.init()))
            return .none
            
        case .binding(\.nickname):
            return .none
            
        case .binding:
            return .none
            
        case .path:
            return .none
        }
    }
}

