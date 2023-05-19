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
        var mode: DiaryCreateMode = .photo
        var date: Date
        var selectedImage: UIImage? = nil
        @BindingState var content: String = ""
        @PresentationState var destination: Destination.State? = nil
    }
    
    enum DiaryCreateMode: Equatable {
        case photo
        case content
    }
    
    // MARK: Action
    
    enum Action: Equatable, BindableAction {
        case imageAreaTapped
        case imageSelected(UIImage)
        case imagePickerDismissed
        case closeButtonTapped
        case saveButtonTapped
        case saveResponse(TaskResult<Bool>)
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
    }
    
    // MARK: Destination
    
    struct Destination: Reducer {
        enum State: Equatable {
            case imagePicker
        }
        
        enum Action: Equatable {
            case imagePicker
        }
        
        var body: some ReducerOf<Self> {
            EmptyReducer()
        }
    }
    
    // MARK: Dependency
    
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.persistence) private var persistence
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .imageAreaTapped:
            state.destination = .imagePicker
            return .none
            
        case let .imageSelected(image):
            state.selectedImage = image
            state.destination = nil
            state.mode = .content
            return .none
            
        case .imagePickerDismissed:
            state.destination = nil
            return .none
            
        case .closeButtonTapped:
            return .fireAndForget { await dismiss() }
            
        case .saveButtonTapped:
            return .fireAndForget { await dismiss() }
//            return .task { [imageData = state.selectedImage?.jpegData(compressionQuality: 1.0), date = state.date, content = state.content] in
//                await .saveResponse(
//                    TaskResult { 
//                        try persistence.save(imageData, date, content)
//                        return true
//                    }
//                )
//            }
            
        case .saveResponse(.success):
            // TODO: 무언가 예쁜 확인
            return .fireAndForget { await dismiss() }
            
        case .saveResponse(.failure):
            // TODO: 실패한거 알리기
            return .none
            
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
                    if viewStore.mode == .photo { diaryImageView }
                    else { diaryContent }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var navigationBar: some View {
        HStack(spacing: .zero) { 
            closeButton
            Spacer()
            if viewStore.mode == .content { saveButton }
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
        Text(viewStore.mode == .photo ? "오늘의 추억은\n무엇인가요?" : "오늘 하루는\n어땠어요?")
            .font(garamond: .heading2)
            .foregroundColor(.text_primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .debug()
            .padding(.vertical, 12)
    }
    
    private var diaryImageView: some View {
        ZStack(alignment: .bottom) { 
            diaryImage
            VStack(spacing: .zero) { 
                Text("1")
                    .font(garamond: .hero)
                    .foregroundColor(.text_disabled)
                
                Text("monday")
                    .font(garamond: .body2)
                    .foregroundColor(.text_disabled)
            }
            .padding(24)
        }
    }
    
    @ViewBuilder
    private var diaryImage: some View {
        if let image = viewStore.selectedImage {
            Image(uiImage: image)
                .resizable()
                .frame(height: 500)
                .frame(maxWidth: .infinity)
                .cornerRadius(24)
                .contentShape(Rectangle())
                .onTapGesture { viewStore.send(.imageAreaTapped) }
        } else {
            // FIXME: 임시 뷰
            Color.elevated
                .frame(height: 500)
                .frame(maxWidth: .infinity)
                .cornerRadius(24)
                .contentShape(Rectangle())
                .onTapGesture { viewStore.send(.imageAreaTapped) }
        }
    }
    
    private var diaryContent: some View {
        VStack(spacing: .zero) { 
            Button { } label: { 
                Text("soso")
                    .font(garamond: .heading3)
                    .padding(.horizontal, 16)
                    .foregroundColor(.day_white)
                    .background(Color.day_brown)
                    .cornerRadius(20)
            }
//            .debug()
            .padding(.bottom, 16)
            
            Text(viewStore.date.yearMonthDay)
                .font(garamond: .heading4)
                .foregroundColor(.day_brown)
                .padding(.bottom, 24)
            
            ZStack(alignment: .leading) {
                if viewStore.content.isEmpty {
                    Text("오늘 하루는 어땠어요?")
                        .font(pretendard: .body2)
                        .foregroundColor(.day_black)
                        .padding(.leading, 16)
                        .padding(.top, 12)
                        .frame(maxHeight: .infinity, alignment: .topLeading)
                }
                
                TextEditor(text: viewStore.binding(\.$content))
                    .font(Font(UIFont(name: "Pretendard-Regular", size: 16)!))
                    .foregroundColor(.grey80)
                    .autocorrectionDisabled(true)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                    .background(Color.day_white)
                    .opacity(viewStore.content.isEmpty ? 0.7 : 1)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity, minHeight: 500)
        .background(Color.day_brown_light)
        .cornerRadius(24)
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
    }
}