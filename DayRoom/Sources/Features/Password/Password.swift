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
        
    }
    
    // MARK: Action
    
    enum Action: Equatable {
        
    }
    
    // MARK: Dependency
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
            
        }
    }
}

