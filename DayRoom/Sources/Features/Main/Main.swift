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
        var date: Date = .now
        
        var diaryFeed: DiaryFeed.State = .init()
        var path: StackState<Path.State> = .init()
        @PresentationState var destination: Destination.State? = nil
    }
    
    // MARK: Action
    
    enum Action: Equatable {
        case diaryFeed(DiaryFeed.Action)
        case path(StackAction<Path.State, Path.Action>)
        case destination(PresentationAction<Destination.Action>)
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
    
    // MARK: Destination
    
    struct Destination: Reducer {
        enum State: Equatable {
            case diaryCreate(DiaryCreate.State)
        }
        
        enum Action: Equatable {
            case diaryCreate(DiaryCreate.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.diaryCreate, action: /Action.diaryCreate) { 
                DiaryCreate()
            }
        }
    }
    
    // MARK: Dependency
    
    @Dependency(\.preferences) private var preferences 
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Scope(state: \.diaryFeed, action: /Action.diaryFeed) { 
            DiaryFeed()
        }
        
        Reduce(core)
            .forEach(\.path, action: /Action.path) { Path() }
            .ifLet(\.$destination, action: /Action.destination) { Destination() }
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .diaryFeed(.delegate(action)):
            switch action {
            case .settingButtonTapped:
                state.path.append(.setting(.init(
                    nickname: preferences.nickname ?? "", 
                    isUsingPassword: !preferences.password.isNil
                )))
                return .none
                
            case .createButtonTapped:
                state.destination = .diaryCreate(.init(date: state.date))
                return .none
                
            case .todayCardTapped:
                state.destination = .diaryCreate(.init(date: .now))
                return .none
            }
            
        case let .diaryFeed(action):
            return .none
            
        case let .path(.element(id: id, action: .setting(.delegate(action)))):
            switch action {
            case let .settingRowTapped(row):
                switch row {
                case .lock:
                    state.path.append(.passwordSetting(.init(isUsingPassword: preferences.password.isNil ? false : true)))
                    return .none
                    
                case .whoMadeThis:
                    // 만든 사람들 페이지로 이동
                    return .none
                    
                case .version:
                    return .none
                }
                
            case .myCloverButtonTapped:
                // 클로버 페이지로 이동
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
            
        case .destination:
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
            DiaryFeedView(store: store.scope(state: \.diaryFeed, action: Main.Action.diaryFeed))
                .fullScreenCover(
                    store: store.scope(state: \.$destination, action: Main.Action.destination), 
                    state: /Main.Destination.State.diaryCreate, 
                    action: Main.Destination.Action.diaryCreate, 
                    content: DiaryCreateView.init
                )
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

