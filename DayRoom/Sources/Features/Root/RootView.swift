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
        SwitchStore(store) { state in
            switch state {
            case .splash:
                Image("app_logo")
                    .onAppear { viewStore.send(.onAppear) }       
                
            case .nickname:
                CaseLet(/Root.State.nickname, action: Root.Action.nickname) { store in
                    NicknameView(store: store)
                }
                
            case .password:
                CaseLet(/Root.State.password, action: Root.Action.password) { store in
                    PasswordView(store: store)
                }
                
            case .feed:
                CaseLet(/Root.State.feed, action: Root.Action.feed) { store in
                    FeedView(store: store)
                }
                
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(
            store: .init(
                initialState: .splash, 
                reducer: Root()
            )
        )
    }
}
