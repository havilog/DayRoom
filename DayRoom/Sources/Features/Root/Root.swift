//
//  Root.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/08.
//

import SwiftUI
import Foundation
import ComposableArchitecture

struct Root: Reducer {
    
    // MARK: State
    
    struct State: Equatable {
        var destination: Destination.State = .splash
    }
    
    struct Destination: Reducer {
        enum State: Equatable {
            case splash
            case welcome
            case nickname(Nickname.State)
            case password(Password.State)
            case main(Main.State)
        }
        enum Action: Equatable {
            case nickname(Nickname.Action)
            case password(Password.Action)
            case main(Main.Action)
        }
        var body: some ReducerProtocolOf<Self> {
            Scope(state: /State.nickname, action: /Action.nickname) {
                Nickname()
            }
            Scope(state: /State.password, action: /Action.password) {
                Password()
            }
            Scope(state: /State.main, action: /Action.main) {
                Main()
            }
        }
    }
    
    // MARK: Action
    
    enum Action: Equatable {
        case onFirstAppear
        case splashCompleted
        case welcomeAnimationFinished
        
        case destination(Destination.Action)
    }
    
    // MARK: Dependency
    
    @Dependency(\.continuousClock) private var clock
    @Dependency(\.preferences) private var preferences
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Scope(state: \State.destination, action: /Action.destination) { 
            Destination()
        }
        
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onFirstAppear:
            return .task { 
                try await self.clock.sleep(for: .seconds(1))
                return .splashCompleted
            }
            .animation()
            
        case .splashCompleted:
            guard preferences.nickname.isNotNil else { 
                state.destination = .nickname(.init(mode: .onboarding)) 
                return .none
            }
            
            if preferences.password.isNil {
                state.destination = .main(.init())
            } else {
                state.destination = .password(.init(mode: .normal))
            }
            
            return .none
            
        case .welcomeAnimationFinished:
            if preferences.password.isNil {
                state.destination = .main(.init())
            } else {
                state.destination = .password(.init(mode: .normal))
            }
            return .none
            
        case let .destination(.nickname(.delegate(action))):
            switch action {
            case .nicknameDetermined:
                state.destination = .welcome
                return .task {
                    try await clock.sleep(for: .seconds(2.5))
                    return .welcomeAnimationFinished
                }
            }
            
        case let .destination(.password(.delegate(action))):
            switch action {
            case .passwordConfirmed:
                state.destination = .main(.init())
                return .none
            }
            
        case .destination:
            return .none
        }
    }
}

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
                Image("launch_screen")
                
            case .welcome:
                WelcomeView()
                    .transition(.opacity.animation(.default))
                
            case .nickname:
                CaseLet(
                    /Root.Destination.State.nickname, 
                     action: Root.Destination.Action.nickname
                ) { store in
                    NavigationStack {
                        NicknameView(store: store)
                    }
                    .transition(.opacity.animation(.default))
                }
                
            case .password:
                CaseLet(
                    /Root.Destination.State.password, 
                     action: Root.Destination.Action.password
                ) { store in
                    PasswordView(store: store)
                        .transition(.opacity.animation(.default))
                }
                
            case .main:
                CaseLet(
                    /Root.Destination.State.main, 
                     action: Root.Destination.Action.main
                ) { store in
                    MainView(store: store)
                        .transition(.opacity.animation(.default))
                }
            }
        }
    }
}

struct WelcomeView: View {
    var body: some View {
        LottieView(jsonName: "envelope motion", loopMode: .playOnce)
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
