//
//  DiaryCard.swift
//  DayRoom
//
//  Created by 한상진 on 2023/06/01.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture

struct DiaryCard: Reducer {
    
    enum CardMode: Equatable {
        case feed
        case create
    }
    
    enum CardPage: Equatable {
        case photo
        case content
    }
    
    // MARK: State
    
    struct State: Equatable, Identifiable {
        let id: UUID = .init()
        var date: Date
        var mood: DiaryMood
        var selectedImage: UIImage?
        var cardMode: CardMode
        var page: CardPage = .photo
        @BindingState var content: String = ""
        @BindingState var selectedImageData: PhotosPickerItem? = nil
    }
    
    // MARK: Action
    
    enum Action: Equatable, BindableAction {
        case viewTapped
        case onLongPressGesture
        case binding(BindingAction<State>)
        case delegate(Delegate)
        enum Delegate: Equatable {
            case needPhotoPicker
            case onLongPressGesture
        }
    }
    
    // MARK: Dependency
    
    @Dependency(\.feedbackGenerator) private var feedbackGenerator 
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .viewTapped:
            if state.page == .photo, state.cardMode == .create {
                return .merge(
                    .run { _ in await feedbackGenerator.impact(.soft) },
                    .send(.delegate(.needPhotoPicker))  
                ) 
            } 
            guard state.cardMode == .feed else { return .none }
            return .merge(
                .run { _ in await feedbackGenerator.impact(.soft) },
                flip(&state)  
            ) 
            
        case .onLongPressGesture:
            return .merge(
                .run { _ in await feedbackGenerator.impact(.medium) },
                .send(.delegate(.onLongPressGesture))
            )
            
        case .binding(\.$selectedImageData):
            // state.selectedImage 바꿔주기
            return .none
            
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
                .flip(opacity: viewStore.page == .photo ? 1 : 0)
                .rotation3DEffect(
                    .degrees(viewStore.page == .photo ? 0 : 180), 
                    axis: (x: .zero, y: -1, z: .zero),
                    perspective: 0.2
                )
            
            contentView
                .flip(opacity: viewStore.page == .photo ? 0 : 1)
                .rotation3DEffect(
                    .degrees(viewStore.page == .photo ? -180 : 0), 
                    axis: (x: .zero, y: -1, z: .zero),
                    perspective: 0.2
                )
        }
        .animation(.easeInOut(duration: 0.7), value: viewStore.page)
        .onTapGesture {
            hideKeyboard()
            viewStore.send(.viewTapped) 
        }
        .onLongPressGesture { viewStore.send(.onLongPressGesture) }
    }
    
    private var photoView: some View {
        ZStack(alignment: .bottom) {
            photoContent(viewStore.selectedImage)
                .frame(maxWidth: UIScreen.main.bounds.size.width - 40)
                .frame(height: (UIScreen.main.bounds.size.width - 40) / 3 * 4)
                .fixedSize()
                .cornerRadius(24)
            
            if viewStore.selectedImage != nil {
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .day_black.opacity(0.05)]), 
                    startPoint: .top, 
                    endPoint: .bottom
                )
                .cornerRadius(24)
            }
                
            
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
    
    @State var test: PhotosPickerItem?
    
    @ViewBuilder
    private func photoContent(_ image: UIImage?) -> some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            PhotosPicker(selection: $test) { 
                Image(viewStore.mood.imageName)
                    .resizable()
                    .clipped()
                    .opacity(viewStore.mood.backgroundOpacity)
            }
        }
    }
    
    private var contentView: some View {
        VStack(spacing: .zero) { 
            Text(viewStore.mood.title)
                .font(garamond: .heading3)
                .foregroundColor(viewStore.mood.foregroundColor)
                .padding(.bottom, 16)
            
            if viewStore.cardMode == .create {
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
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            } else {
                ScrollView(.vertical, showsIndicators: false) { 
                    Text(viewStore.content)
                        .font(pretendard: .body2)
                        .foregroundColor(.text_primary)
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
//                if viewStore.content.isEmpty {
//                    Text("오늘 하루는 어땠어요?")
//                        .font(pretendard: .body2)
//                        .foregroundColor(.text_disabled)
//                        .frame(
//                            maxWidth: .infinity, 
//                            maxHeight: .infinity, 
//                            alignment: .topLeading
//                        )
//                        .cornerRadius(8)
//                }
        }
        .padding(24)
        .frame(height: (UIScreen.main.bounds.size.width - 40) / 3 * 4)
        .frame(maxWidth: UIScreen.main.bounds.size.width - 40)
        .background(
            Image(viewStore.mood.imageName)
                .resizable()
                .clipped()
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
                    cardMode: .create, 
                    page: .photo
                ), 
                reducer: DiaryCard()
            )
        )
        .previewDisplayName("사진")
        
        DiaryCardView(
            store: .init(
                initialState: .init(
                    date: .today, 
                    mood: .lucky, 
                    cardMode: .create,
                    page: .content 
                ), 
                reducer: DiaryCard()
            )
        )
        .previewDisplayName("일기")
    }
}
