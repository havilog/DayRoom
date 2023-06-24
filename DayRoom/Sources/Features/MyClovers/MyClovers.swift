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
        bodyView
            .navigationBarBackButtonHidden(true)
            .toolbar { 
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { viewStore.send(.backButtonTapped) } label: { 
                        Image("ic_chevron_left_ios_24")
                    }
                    .frame(width: 48, height: 48)
                }
            }
    }
    
    private var bodyView: some View {
        TabView {
            cloverCardView
            cloverCardView
            cloverCardView
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .background(Color.black)
    }
    
    private var cloverCardView: some View {
        VStack(spacing: .zero) { 
            HStack(spacing: .zero) { 
                Text("April, 2023")
                Spacer()
                Text("30")
            }
            .padding(.top, 32)
            .padding(.horizontal, 40)
            
            Spacer()
            
            Color.red
                .padding([.horizontal, .bottom], 40)    
        }
        .frame(width: 311, height: 432)
        .background(Color.day_white)
        .cornerRadius(24)
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
