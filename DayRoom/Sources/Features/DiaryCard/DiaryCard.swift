//
//  DiaryCard.swift
//  DayRoom
//
//  Created by 한상진 on 2023/06/01.
//

import SwiftUI

import ComposableArchitecture

struct DiaryCard: Reducer {
    
    enum CardPage: Equatable {
        case photo
        case content
    }
    
    // MARK: State
    
    struct State: Equatable {
        var canFlipByTouch: Bool = true
        
        var date: Date = .today
        var mood: DiaryMood
        var selectedImage: UIImage? = nil
        @BindingState var content: String = ""
        var page: CardPage = .photo
    }
    
    // MARK: Action
    
    enum Action: Equatable, BindableAction {
        case viewTapped
        case binding(BindingAction<State>)
        case delegate(Delegate)
        enum Delegate: Equatable {
            case needPhotoPicker
        }
    }
    
    // MARK: Dependency
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .viewTapped:
            if state.selectedImage == nil, state.page == .photo {
                return .send(.delegate(.needPhotoPicker))
            }
            
            guard state.canFlipByTouch else { return .none }
            return flip(&state)
            
        case .binding:
            return .none
            
        case .delegate:
            return .none
        }
    }
    
    private func flip(_ state: inout State) -> Effect<Action> {
        if state.page == .photo {
            state.page = .content
        } else {
            state.page = .photo
        }
        
        return .none
    }
}

struct DiaryCardView: View {
    let store: StoreOf<DiaryCard>
    @ObservedObject var viewStore: ViewStoreOf<DiaryCard>
    
    init(store: StoreOf<DiaryCard>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        bodyView
    }
    
    private var bodyView: some View {
        ZStack {
            photoView
                .opacity(viewStore.page == .photo ? 1 : 0)
                .rotation3DEffect(
                    .degrees(viewStore.page == .photo ? 0 : 180), 
                    axis: (x: .zero, y: -1, z: .zero),
                    perspective: 0.3
                )
            contentView
                .opacity(viewStore.page == .photo ? 0 : 1)
                .rotation3DEffect(
                    .degrees(viewStore.page == .photo ? -180 : 0), 
                    axis: (x: .zero, y: -1, z: .zero),
                    perspective: 0.3
                )
        }
        .animation(.easeInOut(duration: 0.75), value: viewStore.page)
        .onTapGesture { viewStore.send(.viewTapped) }
        .debug(.day_brown)
    }
    
    private var photoView: some View {
        ZStack(alignment: .bottom) {
            photoContent(viewStore.selectedImage)
                .frame(height: 500)
                .frame(maxWidth: .infinity)
                .cornerRadius(24)
                .contentShape(Rectangle())
            
            VStack(spacing: .zero) { 
                Text(String(viewStore.date.day))
                    .font(garamond: .hero)
                    .foregroundColor(
                        viewStore.selectedImage == nil ? 
                        viewStore.mood.foregroundColor : .day_white
                    )
                
                Text(viewStore.date.weekday.english)
                    .font(garamond: .body2)
                    .foregroundColor(
                        viewStore.selectedImage == nil ? 
                        viewStore.mood.foregroundColor : .day_white
                    )
            }
            .padding(24)
        }
    }
    
    @ViewBuilder
    private func photoContent(_ image: UIImage?) -> some View {
        if let image {
            Image(uiImage: image).resizable()
        } else {
            Image(viewStore.mood.imageName)
                .resizable()
                .opacity(viewStore.mood.backgroundOpacity)
        }
    }

    private var contentView: some View {
        VStack(spacing: .zero) { 
            Text(viewStore.mood.title)
                .font(garamond: .heading3)
                .foregroundColor(viewStore.mood.foregroundColor)
                .debug()
                .padding(.bottom, 16)
            
            ZStack(alignment: .leading) {
                TextEditor(text: viewStore.binding(\.$content))
                    .font(Font(UIFont(name: "Pretendard-Regular", size: 16)!))
                    .foregroundColor(.grey80)
                    .autocorrectionDisabled(true)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    )
                    .cornerRadius(8)
                    .debug()
                
                if viewStore.content.isEmpty {
                    Text("오늘 하루는 어땠어요?")
                        .font(pretendard: .body2)
                        .foregroundColor(.text_disabled)
                        .frame(maxHeight: .infinity, alignment: .topLeading)
                }
            }
        }
        .padding(24)
        .frame(height: 500)
        .frame(maxWidth: .infinity)
        .background(
            Image(viewStore.mood.imageName)
                .resizable()
                .opacity(viewStore.mood.backgroundOpacity)
        )
        .cornerRadius(24)
    }
}

struct DiaryCardView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryCardView(
            store: .init(
                initialState: .init(
                    date: .today, 
                    mood: .lucky, 
                    page: .photo
                ), 
                reducer: DiaryCard()
            )
        )
        .previewDisplayName("사진")
        
        DiaryCardView(
            store: .init(
                initialState: .init(
                    canFlipByTouch: false,
                    date: .today, 
                    mood: .lucky, 
                    page: .content
                ), 
                reducer: DiaryCard()
            )
        )
        .previewDisplayName("일기")
    }
}
