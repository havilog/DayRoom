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
        var pickedImage: UIImage? = nil
        var date: Date
        @BindingState var content: String = ""
        @PresentationState var destination: Destination.State? = nil
    }
    
    // MARK: Action
    
    enum Action: Equatable, BindableAction {
        case imageAreaTapped
        case closeButtonTapped
        case saveButtonTapped
        case saveResponse(TaskResult<Bool>)
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
    }
    
    // MARK: Destination
    
    struct Destination: Reducer {
        enum State: Equatable {
        }
        
        enum Action: Equatable {
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
            return .none
            
        case .closeButtonTapped:
            return .fireAndForget { await dismiss() }
            
        case .saveButtonTapped:
            return .task { [date = state.date, content = state.content] in
                await .saveResponse(
                    TaskResult { 
                        try persistence.save(.init(), date, content)
                        return true
                    }
                )
            }
            
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
    }
    
    private var bodyView: some View {
        ScrollView {
            VStack(spacing: .zero) {
                closeButton
                diaryImage
                diaryContent
            }
        }
        .background(Color.day_black)
    }
    
    private var closeButton: some View {
        Button { viewStore.send(.closeButtonTapped) } label: { 
            Image("ic_cancel_24") 
                .renderingMode(.template)
                .foregroundColor(.day_white)
        }
        .frame(width: 48, height: 48)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    @ViewBuilder
    private var diaryImage: some View {
        if let image = viewStore.pickedImage {
            Image(uiImage: image)
                .frame(height: 500)
                .frame(maxWidth: .infinity)
                .cornerRadius(24)
                .contentShape(Rectangle())
                .onTapGesture { viewStore.send(.imageAreaTapped) }
        } else {
            // FIXME: 임시 뷰
            Color.day_green_light
                .frame(height: 500)
                .frame(maxWidth: .infinity)
                .cornerRadius(24)
                .contentShape(Rectangle())
                .onTapGesture { viewStore.send(.imageAreaTapped) }
        }
    }
    
    private var diaryContent: some View {
        VStack(spacing: .zero) { 
            Text(viewStore.date.formatted)
                .padding(.bottom, 16)
            TextEditor(text: viewStore.binding(\.$content))
                .autocorrectionDisabled(true)
                .frame(minHeight: 48)
                .border(Color.red)
            Button("save", action: { viewStore.send(.saveButtonTapped) })
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity)
        .background(Color.day_white)
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

