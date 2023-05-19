//
//  FeedFeature.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import SwiftUI
import ComposableArchitecture

struct Feed: Reducer {
    
    // MARK: State
    
    struct State: Hashable {
        
    }
    
    // MARK: Action
    
    enum Action: Equatable {
        case settingButtonTapped
        case createButtonTapped
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case settingButtonTapped
            case createButtonTapped
        }
    }
    
    // MARK: Dependency
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .settingButtonTapped:
            return .send(.delegate(.settingButtonTapped))
            
        case .createButtonTapped:
            return .send(.delegate(.createButtonTapped))
            
        case .delegate:
            return .none
        }
    }
}

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
        bodyView
    }
    
    private var bodyView: some View {
        VStack(spacing: .zero) {
            navigationTitle
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16, alignment: .top)]) { 
                    CardView()
                    CardView()
                    CardView()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .debug(.red)
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var navigationTitle: some View {
        HStack(spacing: .zero) {
            Text("April, 2023")
                .font(garamond: .heading2)
                .foregroundColor(.text_primary)
            
            Spacer()
            
            Button { viewStore.send(.createButtonTapped) } label: { Image("ic_edit_3_24") }
                .frame(width: 48, height: 48)
            
            Button { viewStore.send(.settingButtonTapped) } label: { Image("ic_user_24") }
                .frame(width: 48, height: 48)
        }
        .frame(height: 56)
        .padding(.leading, 20)
        .padding(.trailing, 12)
        .debug()
    }
}

struct CardView: View {
    var body: some View {
        Color.red
            .frame(height: 446)
            .cornerRadius(16)
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FeedView(
                store: .init(
                    initialState: .init(), 
                    reducer: Feed()
                )
            )
        }
    }
}
