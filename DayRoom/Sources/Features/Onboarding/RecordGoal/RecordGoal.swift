//
//  RecordGoal.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import Foundation
import ComposableArchitecture

struct RecordGoal: Reducer {
    
    // MARK: State
    
    struct State: Hashable {
        var isCustomValid: Bool = false
        var isCompleteButtonDisabled: Bool = false //  { !isCustomValid || custom.isEmpty }
        
        @BindingState var custom: String = ""
        @BindingState var goal: GoalOfRecord?
    }
    
    enum GoalOfRecord: Hashable {
        case everytime
        case memory
        case daily
        case emotion
        case longliving
        case custom
        
        var description: String {
            switch self {
            case .everytime: return "모든 순간을 기록하기"
            case .memory: return "추억을 간직하기"
            case .daily: return "일상을 기록하기"
            case .emotion: return "감정을 기록하기"
            case .longliving: return "오랫동안 기억하기"
            case .custom: return "직접 입력하기"
            }
        }
    }
    
    // MARK: Action
    
    enum Action: Equatable, BindableAction {
        case backButtonTapped
        case completeButtonTapped
        
        case binding(BindingAction<State>)
    }
    
    // MARK: Dependency
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .binding(\.$custom):
            state.isCustomValid = validate(custom: state.custom)
            return .none
            
        case .binding:
            return .none
            
        case .backButtonTapped:
            return .none
            
        case .completeButtonTapped:
            return .none
        }
    }
    
    private func validate(custom: String) -> Bool {
        let regex = "[A-Za-z0-9]{0,12}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: custom)
    }
}

