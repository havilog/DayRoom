//
//  Root.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/08.
//

import SwiftUI
import Foundation
import FirebaseAnalytics
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
        case onFirstTask
        case onFirstAppear
        case splashCompleted
        case welcomeAnimationFinished
        
        case willResignActiveNotification
        case didEnterBackgroundNotification
        case didBecomeActiveNotification
        case willEnterForegroundNotification
        
        case destination(Destination.Action)
    }
    
    // MARK: Dependency
    
    @Dependency(\.keychain) private var keychain
    @Dependency(\.continuousClock) private var clock
    @Dependency(\.preferences) private var preferences
    
    @Dependency(\.willResignActiveNotification) private var willResignActiveNotification
    @Dependency(\.didEnterBackgroundNotification) private var didEnterBackgroundNotification
    
    @Dependency(\.didBecomeActiveNotification) private var didBecomeActiveNotification
    @Dependency(\.willEnterForegroundNotification) private var willEnterForegroundNotification
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Scope(state: \State.destination, action: /Action.destination) { 
            Destination()
        }
        
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onFirstTask:
            return .merge(
                .run { send in
                    for await _ in await self.willResignActiveNotification() {
                        await send(.willResignActiveNotification)
                    }
                },
                .run { send in
                    for await _ in await self.didEnterBackgroundNotification() {
                        await send(.didEnterBackgroundNotification)
                    }
                }
            )
            
        case .onFirstAppear:
            // TODO: 임마 대충 해놓은거라 device uuid같은거 떤지게 수정하자
            FirebaseAnalytics.Analytics.logEvent("launch", parameters: nil)
            return .task { 
                try await self.clock.sleep(for: .seconds(1))
                return .splashCompleted
            }
            
        case .splashCompleted, 
                .willResignActiveNotification, 
                .didEnterBackgroundNotification, 
                .didBecomeActiveNotification, 
                .willEnterForegroundNotification:
            guard preferences.nickname.isNotNil else { 
                if case .nickname = state.destination { return .none }
                state.destination = .nickname(.init(mode: .onboarding)) 
                return .none
            }
            
            if keychain.getString(.password).isNil {
                if case .main = state.destination { return .none }
                state.destination = .main(.init())
            } else {
                if case .password = state.destination { return .none }
                state.destination = .password(.init(mode: .normal))
            }
            
            return .none
            
        case .welcomeAnimationFinished:
            if keychain.getString(.password).isNil {
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
            .onFirstTask { await viewStore.send(.onFirstTask).finish() }
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
                SplashView()
                    .transition(.opacity.animation(.default))
                
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

struct SplashView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image("logo_dayroom_symbol")
            Image("logo_dayroom")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.day_background)
    }
}

struct WelcomeView: View {
    var body: some View {
        LottieView(jsonName: "envelope motion", loopMode: .playOnce)
            .background(Color.day_background)
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
