//
//  PasswordView.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import SwiftUI
import ComposableArchitecture

struct PasswordView: View {
    let store: StoreOf<Password>
    @ObservedObject var viewStore: ViewStore<ViewState, Password.Action>
    
    struct ViewState: Equatable {
        init(state: Password.State) {
            
        }
    }
    
    init(store: StoreOf<Password>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init)
    }
    
    var body: some View {
        Text("")
    }
}

struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordView(
            store: .init(
                initialState: .init(), 
                reducer: Password()
            )
        )
    }
}

