//
//  RootView.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/08.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: StoreOf<Root>
    @ObservedObject var viewStore: ViewStore<ViewState, Root.Action>
    
    struct ViewState: Equatable {
        init(state: Root.State) {
            
        }
    }
    
    init(store: StoreOf<Root>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init)
    }
    
    var body: some View {
        bodyView
            .onFirstAppear { viewStore.send(.onFirstAppear) }
    }
    
    private var bodyView: some View {
        SwitchStore(
            store.scope(
                state: \.destination, 
                action: Root.Action.destination
            )
        ) { state in
            switch state {
            case .splash:
                Image("app_logo")
                
            case .nickname:
                CaseLet(/Root.Destination.State.nickname, action: Root.Destination.Action.nickname) { store in
                    NicknameView(store: store)
                }
                
            case .password:
                CaseLet(/Root.Destination.State.password, action: Root.Destination.Action.password) { store in
                    PasswordView(store: store)
                }
                
            case .main:
                CaseLet(/Root.Destination.State.main, action: Root.Destination.Action.main) { store in
                    MainView(store: store)
                }
                
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(
            store: .init(
                initialState: .init(), 
                reducer: Root()
            )
        )
    }
}
