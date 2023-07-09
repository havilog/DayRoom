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
            case whoMadeThis(WhoMadeThis.State)
            case passwordSetting(PasswordSetting.State)
            case myClovers(MyClovers.State)
        }
        
        enum Action: Equatable {
            case setting(Setting.Action)
            case whoMadeThis(WhoMadeThis.Action)
            case passwordSetting(PasswordSetting.Action)
            case myClovers(MyClovers.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.setting, action: /Action.setting) { 
                Setting()
            }
            Scope(state: /State.passwordSetting, action: /Action.passwordSetting) { 
                PasswordSetting()
            }
            Scope(state: /State.whoMadeThis, action: /Action.whoMadeThis) { 
                WhoMadeThis()
            }
            Scope(state: /State.myClovers, action: /Action.myClovers) { 
                MyClovers()
            }
        }
    }
    
    // MARK: Destination
    
    struct Destination: Reducer {
        enum State: Equatable {
            case diaryCreate(DiaryCreate.State)
            case dialog(ConfirmationDialogState<DialogAction>)
        }
        
        enum Action: Equatable {
            case diaryCreate(DiaryCreate.Action)
            case dialog(DialogAction)
        }
        
        enum DialogAction: Equatable {
            case edit(id: DiaryCard.State.ID)
            case delete(id: DiaryCard.State.ID)
            case cancel
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.diaryCreate, action: /Action.diaryCreate) { 
                DiaryCreate()
            }
        }
    }
    
    // MARK: Dependency
    
    @Dependency(\.keychain) private var keychain
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
                    isUsingPassword: !keychain.getString(.password).isNil
                )))
                return .none
                
            case .createButtonTapped:
                state.destination = .diaryCreate(.init(date: state.diaryFeed.date))
                return .none
                
            case .todayCardTapped:
                state.destination = .diaryCreate(.init(date: state.diaryFeed.date))
                return .none
                
            case let .diaryLongPressed(id: id):
                state.destination = .dialog(.longPress(id: id))
                return .none
            }
            
        case .diaryFeed:
            return .none
            
        case let .path(.element(id: id, action: .setting(.delegate(action)))):
            switch action {
            case let .settingRowTapped(row):
                switch row {
                case .lock:
                    state.path.append(.passwordSetting(.init(isUsingPassword: keychain.getString(.password).isNil ? false : true)))
                    return .none
                    
                case .whoMadeThis:
                    state.path.append(.whoMadeThis(.init()))
                    return .none
                    
                case .version:
                    return .none
                }
                
            case .myCloverButtonTapped:
                state.path.append(.myClovers(.init(diaries: state.diaryFeed.diaries)))
                return .none
            }
            
        case .path:
            return .none
            
        case let .destination(.presented(.dialog(dialogAction))):
            switch dialogAction {
            case let .edit(id):
                return .none
                
            case let .delete(id):
                return state.diaryFeed.deleteDiary(id: id).map(Action.diaryFeed)
                
            case .cancel:
                return .none
            }
            
        case let .destination(.presented(.diaryCreate(.delegate(action)))):
            switch action {
            case let .diaryCreated(diaryCard):
                return state.diaryFeed.insert(diary: diaryCard).map(Action.diaryFeed)
            }
            
        case .destination:
            return .none
        }
    }
}

extension ConfirmationDialogState where Action == Main.Destination.DialogAction {
    static func longPress(id: DiaryCard.State.ID) -> ConfirmationDialogState {
        return ConfirmationDialogState(
            title: { 
                TextState("title")
            }, 
            actions: {
                ButtonState(action: .edit(id: id)) { 
                    TextState("수정") 
                }
                ButtonState(
                    role: .destructive, 
                    action: .delete(id: id)
                ) {
                    TextState("삭제") 
                }
                ButtonState(role: .cancel, action: .cancel) {
                    TextState("취소") 
                }
            } 
        )   
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
                .confirmationDialog(
                    store: self.store.scope(
                        state: \.$destination, 
                        action: Main.Action.destination
                    ),
                    state: /Main.Destination.State.dialog,
                    action: Main.Destination.Action.dialog
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
            case .whoMadeThis:
                CaseLet(
                    state: /Main.Path.State.whoMadeThis,
                    action: Main.Path.Action.whoMadeThis,
                    then: WhoMadeThisView.init
                )
                
            case .myClovers:
                CaseLet(
                    state: /Main.Path.State.myClovers,
                    action: Main.Path.Action.myClovers,
                    then: MyCloversView.init
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

