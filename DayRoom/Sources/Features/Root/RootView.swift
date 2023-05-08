//
//  RootView.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/08.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: StoreOf<RootFeature>
    @ObservedObject var viewStore: ViewStore<ViewState, RootFeature.Action>
    
    struct ViewState: Equatable {
        init(state: RootFeature.State) {
            
        }
    }
    
    init(store: StoreOf<RootFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init)
    }
    
    var body: some View {
        Text("Hello, World!")
            .onAppear { viewStore.send(.onAppear) }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(
            store: .init(
                initialState: .init(), 
                reducer: RootFeature()
            )
        )
    }
}
