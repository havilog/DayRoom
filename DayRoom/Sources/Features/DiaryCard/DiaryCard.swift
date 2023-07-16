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
        let id: UUID
        var date: Date
        var mood: DiaryMood
        var cardMode: CardMode
        var page: CardPage = .photo
        var selectedImage: Image?
        var isPressing: Bool = false
        @BindingState var content: String = ""
        @BindingState var selectedImageItem: PhotosPickerItem? = nil
    }
    
    // MARK: Action
    
    enum Action: Equatable, BindableAction {
        case viewTapped
        case imageItemSelected(image: Image?)
        case onLongPressGesture
        case onPressing(Bool)
        case binding(BindingAction<State>)
        case delegate(Delegate)
        enum Delegate: Equatable {
            case imageSelected
            case needPhotoPicker
            case onLongPressGesture
        }
    }
    
    // MARK: Dependency
    
    @Dependency(\.continuousClock) private var clock
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
            return .run { send in
                await feedbackGenerator.impact(.medium)
                await send(.delegate(.onLongPressGesture))
            }
            
        case let .onPressing(isPressing):
            guard state.cardMode == .feed else { return .none }
            state.isPressing = isPressing
            return .none
            
        case let .imageItemSelected(image):
            state.selectedImage = image
            return .none
            
        case .binding(\.$selectedImageItem):
            return .run { [imageItem = state.selectedImageItem] send in
                let image = try await imageItem?.loadTransferable(type: Image.self) 
                await send(.imageItemSelected(image: image))
                await send(.delegate(.imageSelected))
            }
            
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
    
    private enum Constant {
        static let maxWidth: CGFloat = UIScreen.main.bounds.size.width - 40
        static let height: CGFloat = (UIScreen.main.bounds.size.width - 40) / 3 * 4
    }
    
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
        .animation(.spring(), value: viewStore.page)
        .animation(.spring(), value: viewStore.isPressing)
        .onTapGesture {
            hideKeyboard()
            viewStore.send(.viewTapped) 
        }
        .onLongPressGesture(
            minimumDuration: 0.3,
            perform: { viewStore.send(.onLongPressGesture) },
            onPressingChanged: { viewStore.send(.onPressing($0)) }
        )
    }
    
    @ViewBuilder
    private var photoView: some View {
        if viewStore.cardMode == .create {
            PhotosPicker(
                selection: viewStore.binding(\.$selectedImageItem),
                matching: .images
            ) {
                photoViewWithMask
            }
            .buttonStyle(.plain)
        } else {
            photoViewWithMask
        }
    }
    
    private var photoViewWithMask: some View {
        ZStack(alignment: .bottom) {
            photoContent(viewStore.selectedImage)
                .frame(maxWidth: viewStore.isPressing ? Constant.maxWidth * 1.03 : Constant.maxWidth)
                .frame(height: viewStore.isPressing ? Constant.height * 1.03 : Constant.height)
                .fixedSize()
                .cornerRadius(20)
                .animation(.spring(), value: viewStore.selectedImage)
            
            if viewStore.selectedImage != nil {
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .day_black.opacity(0.05)]), 
                    startPoint: .top, 
                    endPoint: .bottom
                )
                .cornerRadius(20)
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
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
    }
    
    @ViewBuilder
    private func photoContent(_ image: Image?) -> some View {
        if let image {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .transition(.opacity.animation(.spring()))
        } else {
            Image(viewStore.mood.imageName)
                .resizable()
                .clipped()
                .opacity(viewStore.mood.backgroundOpacity)
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
        }
        .padding(24)
        .frame(maxWidth: viewStore.isPressing ? Constant.maxWidth * 1.03 : Constant.maxWidth)
        .frame(height: viewStore.isPressing ? Constant.height * 1.03 : Constant.height)
        .background(
            Image(viewStore.mood.imageName)
                .resizable()
                .clipped()
                .opacity(viewStore.mood.backgroundOpacity)
        )
        .cornerRadius(20)
    }
}

struct DiaryCardView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryCardView(
            store: .init(
                initialState: .init(
                    id: .init(), 
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
                    id: .init(),
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
