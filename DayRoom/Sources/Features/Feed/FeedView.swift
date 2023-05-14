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
        bodyView
    }
    
    private var bodyView: some View {
        ZStack {
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
            
            createButton
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 48)
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var navigationTitle: some View {
        HStack(spacing: .zero) {
            Color.clear.frame(width: 48, height: 48)
            
            Spacer()
            
            Text("April, 2023")
                .font(garamond: .heading2)
                .foregroundColor(.text_primary)
            
            Spacer()
            
            Button { viewStore.send(.settingButtonTapped) } label: { Image("ic_user_24") }
                .frame(width: 48, height: 48)
        }
        .frame(height: 56)
        .padding(.horizontal, 12)
        .debug()
    }
    
    private var createButton: some View {
        Button { viewStore.send(.createButtonTapped) } label: { Image("ic_plus_24") }
            .frame(width: 56, height: 56)
            .background(Color.day_green)
            .cornerRadius(28)
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
