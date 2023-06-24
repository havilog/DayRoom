//
//  MyClovers.swift
//  DayRoom
//
//  Created by 한상진 on 2023/06/24.
//

import SwiftUI
import ComposableArchitecture

// [[month: Int]]

struct MyClovers: Reducer {
    
    // MARK: State
    
    struct State: Equatable {
        let diaryDates: [Date]
    }
    
    // MARK: Action
    
    enum Action: Equatable {
        case backButtonTapped
    }
    
    // MARK: Dependency
    
    @Dependency(\.dismiss) private var dismiss
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .backButtonTapped:
            return .run { _ in await dismiss() }
        }
    }
}


struct MyCloversView: View {
    let store: StoreOf<MyClovers>
    @ObservedObject var viewStore: ViewStoreOf<MyClovers>
    
    init(store: StoreOf<MyClovers>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        TabView {
            Color.red
        }
    }
}

struct MyCloversView_Previews: PreviewProvider {
    static var previews: some View {
        MyCloversView(
            store: .init(
                initialState: .init(diaryDates: []), 
                reducer: MyClovers()
            )
        )
    }
}
