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
        
        case diarySaveResponse
        case diaryUpdateResponse(UUID)
        case diaryDeleteResponse(Diary)
    }
    
    // MARK: Path
    
    struct Path: Reducer {
        enum State: Equatable {
            case setting(Setting.State)
            case whoMadeThis(WhoMadeThis.State)
            case privacy(Privacy.State)
            case passwordSetting(PasswordSetting.State)
            case myClovers(MyClovers.State)
        }
        
        enum Action: Equatable {
            case setting(Setting.Action)
            case whoMadeThis(WhoMadeThis.Action)
            case privacy(Privacy.Action)
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
            Scope(state: /State.privacy, action: /Action.privacy) { 
                Privacy()
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
    @Dependency(\.persistence) private var persistence
    
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
                    cloversCount: state.diaryFeed.diaries.count
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
            
        case let .path(.element(id: _, action: .setting(.delegate(action)))):
            switch action {
            case let .settingRowTapped(row):
                switch row {
                case .lock:
                    state.path.append(.passwordSetting(.init(isUsingPassword: !keychain.getString(.password).isNil)))
                    return .none
                    
                case .whoMadeThis:
                    state.path.append(.whoMadeThis(.init()))
                    return .none
                    
                case .privacy:
                    state.path.append(.privacy(.init()))
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
                if var diary = state.diaryFeed.diaries[id: id] {
                    diary.cardMode = .create
                    state.destination = .diaryCreate(.init(card: diary, date: diary.date))
                }
                return .none
                
            case let .delete(id):
                return .run { send in
                    let existingDiaries = try persistence.load()
                    if let existingDiary = existingDiaries.first(where: { $0.id == id }) {
                        await send(.diaryDeleteResponse(existingDiary))
                    }
                }
                
            case .cancel:
                return .none
            }
            
        case let .destination(.presented(.diaryCreate(.delegate(action)))):
            switch action {
            case .diarySaveButtonTapped:
                return .run { [state] send in
                    guard case let .diaryCreate(createState) = state.destination else { return }
                    let imageData = try await createState.card?.selectedImageItem?.loadTransferable(type: Data.self)
                    let existingDiaries = try persistence.load()
                    if let existingDiary = existingDiaries.first(where: { $0.id == createState.card?.id }) {
                        try persistence.edit(
                            existingDiary,
                            imageData, 
                            createState.card?.date ?? createState.date,
                            createState.card?.content,
                            createState.card?.mood.rawValue
                        )
                        await send(.diaryUpdateResponse(existingDiary.id!))
                    } else {
                        try persistence.save(
                            createState.card?.id,
                            imageData, 
                            createState.card?.date ?? createState.date,
                            createState.card?.content,
                            createState.card?.mood.rawValue
                        )
                        await send(.diarySaveResponse)
                    }
                }
            }
            
        case .destination:
            return .none
            
        case .diarySaveResponse:
            guard 
                case let .diaryCreate(createState) = state.destination, 
                let newDiary = createState.card
            else { return .none }
            return state.diaryFeed.insert(newDiary: newDiary).map(Action.diaryFeed)
            
        case let .diaryUpdateResponse(id):
            guard 
                case let .diaryCreate(createState) = state.destination, 
                let updatedDiary = createState.card
            else { return .none }
            return state.diaryFeed.update(id: id, diary: updatedDiary).map(Action.diaryFeed)
            
        case let .diaryDeleteResponse(diary):
            return state.diaryFeed.delete(diary: diary).map(Action.diaryFeed)
        }
    }
}

extension ConfirmationDialogState where Action == Main.Destination.DialogAction {
    static func longPress(id: DiaryCard.State.ID) -> ConfirmationDialogState {
        return ConfirmationDialogState(
            title: { 
                TextState("title".localized)
            }, 
            actions: {
                ButtonState(action: .edit(id: id)) { 
                    TextState("수정".localized) 
                }
                ButtonState(
                    role: .destructive, 
                    action: .delete(id: id)
                ) {
                    TextState("삭제".localized) 
                }
                ButtonState(role: .cancel, action: .cancel) {
                    TextState("취소".localized) 
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
                    /Main.Path.State.setting,
                    action: Main.Path.Action.setting,
                    then: SettingView.init
                )
            case .passwordSetting:
                CaseLet(
                    /Main.Path.State.passwordSetting,
                    action: Main.Path.Action.passwordSetting,
                    then: PasswordSettingView.init
                )
            case .whoMadeThis:
                CaseLet(
                    /Main.Path.State.whoMadeThis,
                    action: Main.Path.Action.whoMadeThis,
                    then: WhoMadeThisView.init
                )
                
            case .privacy:
                CaseLet(
                    /Main.Path.State.privacy,
                    action: Main.Path.Action.privacy,
                    then: PrivacyView.init
                )
                
            case .myClovers:
                CaseLet(
                    /Main.Path.State.myClovers,
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

