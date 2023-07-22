//
//  DiaryFeedFeature.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import SwiftUI
import ComposableArchitecture

struct DiaryFeed: Reducer {
    
    // MARK: State
    
    struct State: Equatable {
        var diaries: IdentifiedArrayOf<DiaryCard.State> = .init()
        var isWrittenToday: Bool {
            diaries.isEmpty ? false : diaries.map(\.date).contains(where: \.isToday)
        }
        
        @BindingState var date: Date = .now
        @PresentationState var destination: Destination.State? = nil
    }
    
    // MARK: Action
    
    enum Action: Equatable, BindableAction {
        case onFirstAppear
        case navigationTitleTapped
        case settingButtonTapped
        case createButtonTapped
        case todayCardTapped
        case invalidDateSelected
        case dateSelectComplete
        case diaryCard(id: DiaryCard.State.ID, action: DiaryCard.Action)
        case diaryLoadResponse(TaskResult<[Diary]>)
        case datePickerDismissed
        case remove(diary: Diary)
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
        
        enum Delegate: Equatable {
            case settingButtonTapped
            case createButtonTapped
            case todayCardTapped
            case diaryLongPressed(id: DiaryCard.State.ID)
        }
    }
    
    // MARK: Destination
    
    struct Destination: Reducer {
        enum State: Equatable {
            case datePicker
            case alert(AlertState<Action.Alert>)
        }
        
        enum Action: Equatable {
            case datePicker
            case alert(Alert)
            enum Alert {
                case confirmInvalidDate
                case confirmDateSelectComplete
            }
        }
        
        var body: some ReducerOf<Self> {
            EmptyReducer()
        }
    }
    
    // MARK: Dependency
    
    @Dependency(\.continuousClock) private var clock
    @Dependency(\.persistence) private var persistence
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce(core)
            .forEach(\.diaries, action: /Action.diaryCard) { 
                DiaryCard()
            }
            .ifLet(\.$destination, action: /Action.destination) {
                Destination()
            }
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onFirstAppear:
            return .task { 
                await .diaryLoadResponse(TaskResult { return try persistence.load() })
            }
            
        case .navigationTitleTapped:
            // 원래 달력 뜨는데 안뜨게 막음
            return .none
            
        case .settingButtonTapped:
            return .send(.delegate(.settingButtonTapped))
            
        case .createButtonTapped:
            return .send(.delegate(.createButtonTapped))
            
        case .todayCardTapped:
            return .send(.delegate(.todayCardTapped))
            
        case .dateSelectComplete:
            state.destination = .alert(.selectComplete)
            return .none
            
        case .invalidDateSelected:
            state.destination = .alert(.invalidDate)
            state.date = .today
            return .none
            
        case let .diaryCard(id, .delegate(.onLongPressGesture)):
            return .send(.delegate(.diaryLongPressed(id: id)))
            
        case .diaryCard:
            return .none
            
        case let .diaryLoadResponse(.success(diaries)):
            let diaryState: [DiaryCard.State] = diaries
                .map { diary in
                    return DiaryCard.State.init(
                        id: diary.id ?? .init(),
                        date: diary.date ?? .now, 
                        mood: DiaryMood(rawValue: diary.mood ?? "lucky") ?? .lucky, 
                        cardMode: .feed, 
                        page: .photo,
                        selectedImage: .init(uiImage: .init(data: diary.image ?? .init()) ?? .init()),
                        content: diary.content ?? "",
                        selectedImageItem: nil
                    )
                }
                .sorted { $0.date > $1.date }
            state.diaries = .init(uniqueElements: diaryState)
            return .none
            
        case .diaryLoadResponse(.failure):
            return .none
            
        case .datePickerDismissed:
            state.destination = .none
            return .none
            
        case let .remove(diary):
            persistence.remove(diary)
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
            return .run { send in
                try await clock.sleep(for: .seconds(0.6))
                await send(.dateSelectComplete)
            }
            
        case .binding:
            return .none
            
        case .delegate:
            return .none
        }
    }
}

extension AlertState where Action == DiaryFeed.Destination.Action.Alert {
    static let invalidDate = Self {
        TextState("날짜 변경 불가".localized)
    } actions: {
        ButtonState(action: .send(.confirmInvalidDate, animation: .default)) {
            TextState("확인".localized)
        }
    } message: {
        TextState("오늘 이후의 날짜를 선택 할 수 없어요 :(\n일기가 오늘 날짜로 변경돼요.".localized)
    }
    
    static let selectComplete = Self {
        TextState("날짜 변경 완료".localized)
    } actions: {
        ButtonState(action: .send(.confirmDateSelectComplete, animation: .default)) {
            TextState("확인".localized)
        }
    } message: {
        TextState("선택한 날짜로 변경이 완료되었어요!".localized)
    }
}

extension DiaryFeed.State {
    mutating func delete(diary: Diary) -> Effect<DiaryFeed.Action> {
        if let id = diary.id { self.diaries.remove(id: id) }
        
        return .run { send in
            await send(.remove(diary: diary))
        }
    }
    
    /// 1.
    /// 23.07.12 -> 2에 들어가야함
    /// firstIndex == 2
    /// insert at 2
    /// [23.07.22, 23.07.19, 22. 08. 10]
    /// 
    /// 2. 
    /// [23.07.09]
    /// 23.07.6 -> last에 들어가야함
    /// firstIndex == nil
    /// index == 1
    /// insert at 2
    mutating func insert(newDiary: DiaryCard.State) -> Effect<DiaryFeed.Action> {
        var feedDiary = newDiary
        feedDiary.cardMode = .feed
        feedDiary.page = .photo
        if let index = self.diaries.firstIndex(where: { $0.date < newDiary.date }) {
            self.diaries.updateOrInsert(feedDiary, at: index)    
        } else {
            self.diaries.append(feedDiary)
        }
        return .none
    }
    
    mutating func update(id: UUID, diary: DiaryCard.State) -> Effect<DiaryFeed.Action> {
        var feedDiary = diary
        feedDiary.cardMode = .feed
        feedDiary.page = .photo
        if let existingDiaryIndex = self.diaries.index(id: id) {
            self.diaries.remove(at: existingDiaryIndex)
            self.diaries.insert(feedDiary, at: existingDiaryIndex)    
        }
        return .none
    }
}

struct DiaryFeedView: View {
    let store: StoreOf<DiaryFeed>
    @ObservedObject var viewStore: ViewStoreOf<DiaryFeed>
    
    init(store: StoreOf<DiaryFeed>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        bodyView
            .background(Color.day_background)
            .onFirstAppear { viewStore.send(.onFirstAppear) }
            .alert(
                store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                state: /DiaryFeed.Destination.State.alert,
                action: DiaryFeed.Destination.Action.alert
            )
            .sheet(
                isPresented: .init(
                    get: { viewStore.state.destination == .datePicker }, 
                    set: { if !$0 { viewStore.send(.datePickerDismissed) } }
                ),
                onDismiss: { viewStore.send(.datePickerDismissed) }
            ) { DatePickerView(date: viewStore.binding(\.$date)) }
    }
    
    private let oneSizeItem: GridItem = GridItem(.flexible(), alignment: .top)
    
    private var bodyView: some View {
        VStack(spacing: .zero) {
            navigationTitle
            
            ScrollView {
                Spacer().frame(height: 12)
                
                if viewStore.isWrittenToday == false { 
                    emptyCardView
                        .padding(.bottom, 8)
                }
                
                LazyVGrid(columns: [oneSizeItem], spacing: 16) {
                    ForEachStore(
                        store.scope(
                            state: \.diaries, 
                            action: DiaryFeed.Action.diaryCard
                        )
                    ) { store in
                        DiaryCardView(store: store)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .animation(.spring(), value: viewStore.diaries)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var emptyCardView: some View {
        VStack(spacing: .zero) { 
            Spacer()
            Text(String(Date.today.day))
                .font(garamond: .hero)
                .foregroundColor(.text_disabled)
            
            Text(Date.today.weekday.english)
                .font(garamond: .body2)
                .foregroundColor(.text_disabled)
        }
        .padding(24)
        .frame(
            width: UIScreen.main.bounds.size.width - 40,
            height: (UIScreen.main.bounds.size.width - 40) / 3 * 4
        )
        .background(Color.elevated)
        .cornerRadius(24)
        .padding(.horizontal, 20)
        .onTapGesture { viewStore.send(.createButtonTapped) }
    }
    
    private var navigationTitle: some View {
        HStack(spacing: .zero) {
            Text(viewStore.date.dayroomMonth)
                .font(garamond: .heading2)
                .foregroundColor(.text_primary)
                .onTapGesture { viewStore.send(.navigationTitleTapped) }
            
            Spacer()
            
            Button { viewStore.send(.createButtonTapped) } label: { Image("ic_edit_3_24") }
                .frame(width: 48, height: 48)
            
            Button { viewStore.send(.settingButtonTapped) } label: { Image("ic_user_24") }
                .frame(width: 48, height: 48)
        }
        .frame(height: 56)
        .padding(.leading, 20)
        .padding(.trailing, 12)
    }
}

struct DiaryFeedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DiaryFeedView(
                store: .init(
                    initialState: .init(diaries: []), 
                    reducer: DiaryFeed()
                )
            )
        }
    }
}
