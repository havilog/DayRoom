//
//  RecordGoalView.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import SwiftUI
import ComposableArchitecture

struct RecordGoalView: View {
    let store: StoreOf<RecordGoal>
    @ObservedObject var viewStore: ViewStore<ViewState, RecordGoal.Action>
    
    struct ViewState: Equatable {
        init(state: RecordGoal.State) {
            
        }
    }
    
    init(store: StoreOf<RecordGoal>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init)
    }
    
    var body: some View {
        Text("")
    }
}

struct RecordGoalView_Previews: PreviewProvider {
    static var previews: some View {
        RecordGoalView(
            store: .init(
                initialState: .init(), 
                reducer: RecordGoal()
            )
        )
    }
}

