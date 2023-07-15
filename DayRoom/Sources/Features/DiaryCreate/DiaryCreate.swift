//
//  DiaryCreate.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/19.
//

import SwiftUI
import ComposableArchitecture

struct DiaryCreate: Reducer {
    
    // MARK: State
    
    struct State: Equatable {
        var card: DiaryCard.State? = nil
        var isCreateFinished: Bool = false
        
        @BindingState var date: Date
        @PresentationState var destination: Destination.State? = nil
    }
    
    // MARK: Action
    
    enum Action: Equatable, BindableAction {
        case onFirstAppear
        case imagePickerDismissed
        case datePickerDismissed
        case closeButtonTapped
        case saveButtonTapped
        case noteButtonTapped
        case imageButtonTapped
        case calendarButtonTapped
        
        case card(DiaryCard.Action)
        
        case imageSelectedAnimation
        case invalidDateSelected
        case dateSelectComplete
        
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case delegate(Delegate)
        enum Delegate: Equatable {
            case diarySaveButtonTapped
        }
    }
    
    // MARK: Destination
    
    struct Destination: Reducer {
        enum State: Equatable {
            case imagePicker
            case datePicker
            case moodPicker(MoodPicker.State)
            case alert(AlertState<Action.Alert>)
        }
        
        enum Action: Equatable {
            case imagePicker
            case datePicker
            case moodPicker(MoodPicker.Action)
            case alert(Alert)
            enum Alert {
                case confirmInvalidDate
                case confirmDateSelectComplete
            }
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.moodPicker, action: /Action.moodPicker) { 
                MoodPicker()
            }
        }
    }
    
    // MARK: Dependency
    
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.continuousClock) private var clock
    @Dependency(\.persistence) private var persistence
    @Dependency(\.feedbackGenerator) private var feedbackGenerator 
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce(core)
            .ifLet(\.card, action: /Action.card) {
                DiaryCard()
            }
            .ifLet(\.$destination, action: /Action.destination) {
                Destination()
            }
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onFirstAppear:
            if state.card == nil {
                state.destination = .moodPicker(.init())
                return .run { _ in await feedbackGenerator.impact(.rigid) }    
            } else {
                return .none
            }
            
        case .imageSelectedAnimation:
            state.card?.page = .content
            return .none
            
        case .imagePickerDismissed, .datePickerDismissed:
            state.destination = nil
            return .none
            
        case .closeButtonTapped:
            return .run { _ in await dismiss() }
            
        case .saveButtonTapped:
            state.isCreateFinished = true
            return .merge(
                .send(.delegate(.diarySaveButtonTapped)),
                .run { _ in 
                    try await self.clock.sleep(for: .seconds(1.7))
                    await dismiss() 
                }
            )
            
        case .noteButtonTapped:
            state.card?.page = .content
            return .run { _ in await feedbackGenerator.impact(.soft) }
            
        case .imageButtonTapped:
            state.card?.page = .photo
            return .run { _ in await feedbackGenerator.impact(.soft) }
            
        case .calendarButtonTapped:
            state.destination = .datePicker
            return .run { _ in await feedbackGenerator.impact(.soft) }
            
        case let .card(.delegate(action)):
            switch action {
            case .imageSelected:
                state.destination = nil
                return .task { 
                    try await clock.sleep(for: .seconds(0.65))
                    return .imageSelectedAnimation
                }
                
            case .needPhotoPicker:
                state.destination = .imagePicker
                return .none
                
            case .onLongPressGesture:
                return .none
            }
            
        case .card:
            return .none
            
        case .invalidDateSelected:
            state.destination = .alert(.invalidDate)
            state.date = .today
            return state.mutate(date: .today)
            
        case .dateSelectComplete:
            state.destination = .alert(.selectComplete)
            return .none
            
        case let .destination(.presented(.moodPicker(.delegate(action)))):
            switch action {
            case let .moodSelected(mood):
                state.card = .init(
                    id: .init(), 
                    date: state.date, 
                    mood: mood,
                    cardMode: .create
                )
                return .none
            }
            
        case .destination(.dismiss):
            guard state.card?.mood != nil else {
                return .run { _ in await dismiss() }
            }
            return .none
            
        case .destination:
            return .none
            
        case .binding(\.$date):
            state.destination = .none
            guard state.date.isFutureDay == false else {
                return .run { send in
                    try await clock.sleep(for: .seconds(0.6))
                    await send(.invalidDateSelected)
                }
            }
            return .merge(
                state.mutate(date: state.date),
                .run { send in
                    try await clock.sleep(for: .seconds(0.6))
                    await send(.dateSelectComplete)
                }
            )
            
        case .binding:
            return .none
            
        case .delegate:
            return .none
        }
    }
}

extension AlertState where Action == DiaryCreate.Destination.Action.Alert {
    static let invalidDate = Self {
        TextState("날짜 변경 불가")
    } actions: {
        ButtonState(action: .send(.confirmInvalidDate, animation: .default)) {
            TextState("확인")
        }
    } message: {
        TextState("오늘 이후의 날짜를 선택 할 수 없어요 :(\n일기가 오늘 날짜로 변경돼요.")
    }
    
    static let selectComplete = Self {
        TextState("날짜 변경 완료")
    } actions: {
        ButtonState(action: .send(.confirmDateSelectComplete, animation: .default)) {
            TextState("확인")
        }
    } message: {
        TextState("선택한 날짜로 변경이 완료되었어요!")
    }
}

extension DiaryCreate.State {
    mutating func mutate(date: Date) -> Effect<DiaryCreate.Action> {
        self.card?.date = date
        return .none
    }
    
    mutating func mutate(createState: Bool) -> Effect<DiaryCreate.Action> {
        self.isCreateFinished = createState
        return .none
    }
}

struct DiaryCreateView: View {
    let store: StoreOf<DiaryCreate>
    @ObservedObject var viewStore: ViewStoreOf<DiaryCreate>
    
    init(store: StoreOf<DiaryCreate>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    @ViewBuilder
    var body: some View {
        if viewStore.isCreateFinished {
            CreateFinishView()
        } else {
            bodyView
                .onFirstAppear { viewStore.send(.onFirstAppear) }
                .sheet(
                    store: store.scope(state: \.$destination, action: DiaryCreate.Action.destination),
                    state: /DiaryCreate.Destination.State.moodPicker,
                    action: DiaryCreate.Destination.Action.moodPicker,
                    content: MoodPickerView.init
                )
                .alert(
                    store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                    state: /DiaryCreate.Destination.State.alert,
                    action: DiaryCreate.Destination.Action.alert
                )
                .sheet(
                    isPresented: .init(
                        get: { viewStore.state.destination == .datePicker }, 
                        set: { if !$0 { viewStore.send(.datePickerDismissed) } }
                    ),
                    onDismiss: { viewStore.send(.datePickerDismissed) }
                ) { 
                    DatePickerView(date: viewStore.binding(\.$date)) 
                }
        }
    }
    
    private var bodyView: some View {
        VStack(spacing: .zero) { 
            navigationBar
            ScrollView(showsIndicators: false) {
                VStack(spacing: .zero) {
                    title
                    
                    IfLetStore(
                        store.scope(state: \.card, action: DiaryCreate.Action.card), 
                        then: DiaryCardView.init
                    )
                    .transition(.opacity.animation(.spring()))
                    .padding(.bottom, 32)
                    
                    if viewStore.card?.mood != nil {
                        bottomButtons
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var navigationBar: some View {
        HStack(spacing: .zero) { 
            closeButton
            Spacer()
            
            if viewStore.card?.selectedImage != nil, viewStore.card?.content.isEmpty == false {
                saveButton
            }
        }
    }
    
    private var closeButton: some View {
        Button { viewStore.send(.closeButtonTapped) } label: { Image("ic_cancel_24") }
            .frame(width: 48, height: 48)
            .padding(.leading, 12)
    }
    
    private var saveButton: some View {
        Button {
            hideKeyboard()
            viewStore.send(.saveButtonTapped) 
        } label: { 
            Image("ic_check_24") 
        }
        .frame(width: 48, height: 48)
        .padding(.trailing, 8)
    }
    
    private var title: some View {
        Text("오늘의 추억은\n무엇인가요?")
            .font(pretendard: .heading1)
            .foregroundColor(.text_primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 16)
            .padding(.bottom, 24)
            .onTapGesture { hideKeyboard() }
    }
    
    private var bottomButtons: some View {
        HStack(spacing: .zero) { 
            leftButton()
                .transition(.opacity.animation(.spring()))
                .padding(.trailing, 20)
            calendarButton
        }
    }
    
    @ViewBuilder
    private func leftButton() -> some View {
        if viewStore.card?.page == .photo {
            noteButton
        } else {
            imageButton
        }
    }
    
    private var noteButton: some View {
        Button {  viewStore.send(.noteButtonTapped) } label: { 
            Image("ic_note_24")
                .renderingMode(.template)
                .foregroundColor(viewStore.card?.selectedImage == nil ? .text_disabled : .text_primary)
        }
        .frame(width: 52, height: 52)
        .background(Color.day_white)
        .cornerRadius(26)
        .shadow(color: .day_black.opacity(0.03), radius: 2, y: 1)
        .shadow(color: .day_black.opacity(0.03), radius: 6, y: 4)
        .disabled(viewStore.card?.selectedImage == nil ? true : false)
    }
    
    private var imageButton: some View {
        Button {  viewStore.send(.imageButtonTapped) } label: { 
            Image("ic_image_24")
        }
        .frame(width: 52, height: 52)
        .background(Color.day_white)
        .cornerRadius(26)
        .shadow(color: .day_black.opacity(0.03), radius: 2, y: 1)
        .shadow(color: .day_black.opacity(0.03), radius: 6, y: 4)
    }
    
    private var calendarButton: some View {
        Button {  viewStore.send(.calendarButtonTapped) } label: { 
            Image("ic_calendar_24")
        }
        .frame(width: 52, height: 52)
        .background(Color.day_white)
        .cornerRadius(26)
        .shadow(color: .day_black.opacity(0.03), radius: 2, y: 1)
        .shadow(color: .day_black.opacity(0.03), radius: 6, y: 4)
    }
}

struct CreateFinishView: View {
    var body: some View {
        LottieView(jsonName: "clover_motion", loopMode: .playOnce)
            .padding(40)
    }
}

struct DiaryCreateView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryCreateView(
            store: .init(
                initialState: .init(date: .now), 
                reducer: DiaryCreate()
            )
        )
        
        DiaryCreateView(
            store: .init(
                initialState: .init(date: .now), 
                reducer: DiaryCreate()
            )
        )
    }
}
