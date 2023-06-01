//
//  DiaryDetail.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/19.
//

import SwiftUI
import ComposableArchitecture

struct DiaryDetail: Reducer {
    
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

struct DiaryDetailView: View {
    let store: StoreOf<DiaryDetail>
    @ObservedObject var viewStore: ViewStore<ViewState, DiaryDetail.Action>
    
    struct ViewState: Equatable {
        init(state: DiaryDetail.State) {
            
        }
    }
    
    init(store: StoreOf<DiaryDetail>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init)
    }
    
    var body: some View {
        Text("")
    }
}

struct DiaryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryDetailView(
            store: .init(
                initialState: .init(), 
                reducer: DiaryDetail()
            )
        )
    }
}

