//
//  Setting.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/14.
//

import ComposableArchitecture

struct Setting: Reducer {
    
    // MARK: State
    
    struct State: Hashable {
        
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

