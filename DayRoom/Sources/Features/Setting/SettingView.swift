//
//  SettingView.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/08.
//

import SwiftUI
import ComposableArchitecture

struct SettingView: View {
    let store: StoreOf<Setting>
    @ObservedObject var viewStore: ViewStore<ViewState, Setting.Action>
    
    struct ViewState: Equatable {
        init(state: Setting.State) {
            
        }
    }
    
    init(store: StoreOf<Setting>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init)
    }
    
    var body: some View {
        Text("")
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(
            store: .init(
                initialState: .init(), 
                reducer: Setting()
            )
        )
    }
}
