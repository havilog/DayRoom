//
//  FeedView.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import SwiftUI
import ComposableArchitecture

struct FeedView: View {
    let store: StoreOf<Feed>
    @ObservedObject var viewStore: ViewStore<ViewState, Feed.Action>
    
    struct ViewState: Equatable {
        init(state: Feed.State) {
            
        }
    }
    
    init(store: StoreOf<Feed>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init)
    }
    
    var body: some View {
        Text("")
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(
            store: .init(
                initialState: .init(), 
                reducer: Feed()
            )
        )
    }
}

