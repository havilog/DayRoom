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
        var date: Date
        var card: DiaryCard.State? = nil
        var isCreateFinished: Bool = false
        
        @PresentationState var destination: Destination.State? = nil
    }
    
    // MARK: Action
    
    enum Action: Equatable, BindableAction {
        case onFirstAppear
        case imageSelected(UIImage)
        case imagePickerDismissed
        case closeButtonTapped
        case saveButtonTapped
        case noteButtonTapped
        case imageButtonTapped
        case calendarButtonTapped
        
        case card(DiaryCard.Action)
        
        case imageSelectedAnimation
        case saveResponse(TaskResult<Bool>)
        
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        case delegate(Delegate)
        enum Delegate: Equatable {
            case diaryCreated(DiaryCard.State)
        }
    }
    
    // MARK: Destination
    
    struct Destination: Reducer {
        enum State: Equatable {
            case imagePicker
            case moodPicker(MoodPicker.State)
        }
        
        enum Action: Equatable {
            case imagePicker
            case moodPicker(MoodPicker.Action)
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
            state.destination = .moodPicker(.init())
            return .none
            
        case let .imageSelected(image):
            state.card?.selectedImage = image
            state.destination = nil
            return .task { 
                try await clock.sleep(for: .seconds(1))
                return .imageSelectedAnimation
            }
            
        case .imageSelectedAnimation:
            state.card?.page = .content
            return .none
            
        case .imagePickerDismissed:
            state.destination = nil
            return .none
            
        case .closeButtonTapped:
            return .fireAndForget { await dismiss() }
            
        case .saveButtonTapped:
            return .task { [
                imageData = state.card?.selectedImage?.jpegData(compressionQuality: 1.0), 
                date = state.date,
                content = state.card?.content,
                mood = state.card?.mood.rawValue
            ] in
                await .saveResponse(
                    TaskResult { 
                        try persistence.save(imageData, date, content ?? "", mood ?? "lucky")
                        return true
                    }
                )
            }
            
        case .noteButtonTapped:
            state.card?.page = .content
            return .none
            
        case .imageButtonTapped:
            state.card?.page = .photo
            return .none
            
        case .calendarButtonTapped:
            // calendar 띄우기
            return .none
            
        case let .card(.delegate(action)):
            switch action {
            case .needPhotoPicker:
                state.destination = .imagePicker
                return .none
            case .onLongPressGesture:
                return .none
            }
            
        case .card:
            return .none
            
        case .saveResponse(.success):
            guard let diaryCard = state.card else { return .none }
            state.isCreateFinished = true
            return .merge(
                .fireAndForget {
                    try await self.clock.sleep(for: .seconds(1.7))
                    await dismiss() 
                },
                .send(.delegate(.diaryCreated(diaryCard)))
            )
            
        case .saveResponse(.failure):
            // TODO: 실패한거 알리기
            return .none
            
        case let .destination(.presented(.moodPicker(.delegate(action)))):
            switch action {
            case let .moodSelected(mood):
                state.card = .init(
                    date: state.date, 
                    mood: mood,
                    cardMode: .create
                )
                return .none
            }
            
        case .destination:
            return .none
            
        case .binding:
            return .none
            
        case .delegate:
            return .none
        }
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
                .sheet(
                    isPresented: .init(
                        get: { viewStore.state.destination == .imagePicker }, 
                        set: { if !$0 { viewStore.send(.imagePickerDismissed) } }
                    ),
                    onDismiss: { viewStore.send(.imagePickerDismissed) }
                ) {
                    ImagePicker { selectedImage in
                        viewStore.send(.imageSelected(selectedImage))
                    }
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
                    .transition(.opacity.animation(.easeInOut))
                    .padding(.bottom, 32)
                    
                    bottomButtons
                        .opacity(viewStore.card?.mood == nil ? 0 : 1)
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
            leftButton().padding(.trailing, 20)
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
            .padding(24)
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
