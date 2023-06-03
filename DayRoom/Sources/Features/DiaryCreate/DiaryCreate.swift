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
        
        @PresentationState var destination: Destination.State? = nil
    }
    
    // MARK: Action
    
    enum Action: Equatable, BindableAction {
        case onFirstAppear
        case imageSelected(UIImage)
        case imagePickerDismissed
        case closeButtonTapped
        case saveButtonTapped
        
        case card(DiaryCard.Action)
        
        case imageSelectedAnimation
        case saveResponse(TaskResult<Bool>)
        
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
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
                try await clock.sleep(for: .seconds(0.75))
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
                content = state.card?.content
            ] in
                await .saveResponse(
                    TaskResult { 
                        try persistence.save(imageData, date, content ?? "")
                        return true
                    }
                )
            }
            
        case let .card(.delegate(action)):
            switch action {
            case .needPhotoPicker:
                state.destination = .imagePicker
                return .none
            }
            
        case .card:
            return .none
            
        case .saveResponse(.success):
            // TODO: 무언가 예쁜 확인
            return .fireAndForget { await dismiss() }
            
        case .saveResponse(.failure):
            // TODO: 실패한거 알리기
            return .none
            
        case let .destination(.presented(.moodPicker(.delegate(action)))):
            switch action {
            case let .moodSelected(mood):
                state.card = .init(date: state.date, mood: mood)
                return .none
            }
            
        case .destination:
            return .none
            
        case .binding:
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
    
    var body: some View {
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
    
    @ViewBuilder
    private var bodyView: some View {
        VStack(spacing: .zero) { 
            navigationBar
            ScrollView {
                VStack(spacing: .zero) {
                    title
                    
                    IfLetStore(
                        store.scope(state: \.card, action: DiaryCreate.Action.card), 
                        then: DiaryCardView.init
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var navigationBar: some View {
        HStack(spacing: .zero) { 
            closeButton
            Spacer()
        }
    }
    
    private var closeButton: some View {
        Button { viewStore.send(.closeButtonTapped) } label: { Image("ic_cancel_24") }
            .frame(width: 48, height: 48)
            .debug()
            .padding(.leading, 12)
    }
    
    private var saveButton: some View {
        Button("save", action: { viewStore.send(.saveButtonTapped) })
            .frame(width: 48, height: 48)
            .padding(.trailing, 8)
    }
    
    private var title: some View {
        Text("오늘의 추억은\n무엇인가요?")
            .font(pretendard: .heading1)
            .foregroundColor(.text_primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .debug()
            .padding(.top, 24)
            .padding(.bottom, 32)
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

// 이미지
//        if let image = viewStore.selectedImage {
//            Image(uiImage: image)
//                .resizable()
//                .frame(height: 500)
//                .frame(maxWidth: .infinity)
//                .cornerRadius(24)
//                .contentShape(Rectangle())
//                .onTapGesture { viewStore.send(.imageAreaTapped) }
//        } else {

// 플레이스 홀더
//            ZStack(alignment: .leading) {
//                if viewStore.content.isEmpty {
//                    Text("오늘 하루는 어땠어요?")
//                        .font(pretendard: .body2)
//                        .foregroundColor(.day_black)
//                        .padding(.leading, 16)
//                        .padding(.top, 12)
//                        .frame(maxHeight: .infinity, alignment: .topLeading)
//                }
//            }
