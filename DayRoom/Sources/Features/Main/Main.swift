//
//  Home.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/14.
//

import SwiftUI
import ComposableArchitecture

struct Main: Reducer {
    
    // MARK: State
    
    struct State: Equatable {
        var feed: Feed.State = .init()
        var path: StackState<Path.State> = .init()
    }
    
    // MARK: Action
    
    enum Action: Equatable {
        case feed(Feed.Action)
        case path(StackAction<Path.State, Path.Action>)
    }
    
    // MARK: Path
    
    struct Path: Reducer {
        enum State: Equatable {
            case setting(Setting.State)
            case passwordSetting(PasswordSetting.State)
        }
        
        enum Action: Equatable {
            case setting(Setting.Action)
            case passwordSetting(PasswordSetting.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.setting, action: /Action.setting) { 
                Setting()
            }
            Scope(state: /State.passwordSetting, action: /Action.passwordSetting) { 
                PasswordSetting()
            }
        }
    }
    
    // MARK: Dependency
    
    @Dependency(\.preferences) private var preferences 
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Scope(state: \.feed, action: /Action.feed) { 
            Feed()
        }
        
        Reduce(core)
            .forEach(\.path, action: /Action.path) { 
                Path()
            }
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .feed(.delegate(action)):
            switch action {
            case .settingButtonTapped:
                state.path.append(.setting(.init()))
                return .none    
            }
            
        case let .feed(action):
            return .none
            
        case let .path(.element(id: id, action: .setting(.delegate(action)))):
            switch action {
            case let .settingRowTapped(row):
                state.path.append(.passwordSetting(.init(isUsingPassword: preferences.password.isNil ? false : true)))
                return .none
                
            case .backButtonTapped:
                state.path.pop(from: id)
                return .none
            }
            
        case let .path(.element(id: id, action: .passwordSetting(.delegate(action)))):
            switch action {
            case .backButtonTapped:
                state.path.pop(from: id)
                return .none
            }
            
        case .path:
            return .none
        }
    }
}

struct MainView: View {
    let store: StoreOf<Main>
    
    init(store: StoreOf<Main>) {
        self.store = store
    }
    
    var body: some View {
        NavigationStackStore(store.scope(state: \.path, action: Main.Action.path)) { 
            FeedView(store: store.scope(state: \.feed, action: Main.Action.feed))
        } destination: { destination in
            switch destination {
            case .setting:
                CaseLet(
                    state: /Main.Path.State.setting,
                    action: Main.Path.Action.setting,
                    then: SettingView.init
                )
            case .passwordSetting:
                CaseLet(
                    state: /Main.Path.State.passwordSetting,
                    action: Main.Path.Action.passwordSetting,
                    then: PasswordSettingView.init
                )
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(
            store: .init(
                initialState: .init(), 
                reducer: Main()
            )
        )
    }
}

