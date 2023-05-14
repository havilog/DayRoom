//
//  Password.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import ComposableArchitecture

struct Password: Reducer {
    
    // MARK: State
    
    struct State: Equatable {
        var mode: Mode
        var status: Status = .initial
        var informationText: String
        var isPasswordConformIncorrect: Bool = false
        var inputPassword: String = ""
        
        init(mode: Mode) {
            self.mode = mode
            self.informationText = mode.description
        }
    }
    
    enum Password: Identifiable, Hashable {
        case first(Int)
        case second(Int)
        case third(Int)
        case forth(Int)
        var id: String {
            switch self {
            case .first: return "first"
            case .second: return "second"    
            case .third: return "third"    
            case .forth: return "forth"    
            }
        }
    }
    
    enum Mode: Equatable, CustomStringConvertible {
        case normal
        case change
        case new
        
        var description: String {
            switch self {
            case .normal: return "암호 입력"
            case .new: return "비밀번호를 입력해 주세요"
            case .change: return "새로운 비밀번호를 입력해 주세요"
            }
        }
    }
    
    enum Status: Equatable {
        case initial
        case confirm(enteredPassword: String)
    }
    
    // MARK: Action
    
    enum Action: Equatable {
        case closeButtonTapped
        case backButtonTapped
        case keypadTapped(number: String)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case passwordConfirmed
        }
    }
    
    // MARK: Dependency
    
    @Dependency(\.preferences) private var preferences
    @Dependency(\.dismiss) private var dismiss
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .closeButtonTapped:
            return .fireAndForget { await dismiss() }
            
        case .backButtonTapped:
            guard !state.inputPassword.isEmpty else { return .none }
            state.inputPassword.removeLast()
            return .none
            
        case let .keypadTapped(number):
            guard state.inputPassword.count < 4 else { return .none }
            
            state.inputPassword.append(number)
            
            if state.inputPassword.count == 4 {
                switch state.mode {
                case .normal:
                    guard state.inputPassword == preferences.password else {
                        state.isPasswordConformIncorrect = true
                        state.inputPassword.removeAll()
                        return .none
                    }
                    
                    return .send(.delegate(.passwordConfirmed), animation: .default)
                    
                case .new, .change:
                    guard case let .confirm(enteredPassword) = state.status else {
                        state.status = .confirm(enteredPassword: state.inputPassword)
                        state.informationText = "한 번 더 입력해주세요"
                        state.inputPassword.removeAll()
                        return .none 
                    }
                    
                    guard state.inputPassword == enteredPassword else {
                        state.isPasswordConformIncorrect = true
                        state.inputPassword.removeAll()
                        return .none
                    }
                    
                    preferences.password = enteredPassword
                    
                    return .send(.delegate(.passwordConfirmed), animation: .default)
                }
            }
            
            return .none
            
        case .delegate:
            return .none
        }
    }
}
