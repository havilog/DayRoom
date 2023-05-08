//
//  RootFeature.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/08.
//

import Foundation
import ComposableArchitecture

struct RootFeature: Reducer {
    
    // MARK: State
    
    struct State: Equatable, Sendable {
        
    }
    
    // MARK: Action
    
    enum Action: Equatable, Sendable {
        case onAppear
    }
    
    // MARK: Dependency
    
    @Dependency(\.persistence) private var persistence
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onAppear:
            return .none
        }
    }
}
