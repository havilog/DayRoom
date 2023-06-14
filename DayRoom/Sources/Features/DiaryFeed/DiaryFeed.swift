//
//  DiaryFeedFeature.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import SwiftUI
import Kingfisher
import ComposableArchitecture

struct DiaryFeed: Reducer {
    
    // MARK: State
    
    struct State: Equatable {
        var date: Date = .now
        var diaries: IdentifiedArrayOf<DiaryCard.State> = .init()
    }
    
    // MARK: Action
    
    enum Action: Equatable {
        case onFirstAppear
        case settingButtonTapped
        case createButtonTapped
        case todayCardTapped
        case diaryCard(id: DiaryCard.State.ID, action: DiaryCard.Action)
        case diaryLoadResponse(TaskResult<[Diary]>)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case settingButtonTapped
            case createButtonTapped
            case todayCardTapped
        }
    }
    
    // MARK: Dependency
    
    @Dependency(\.persistence) private var persistence 
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Reduce(core)
            .forEach(\.diaries, action: /Action.diaryCard) { 
                DiaryCard()
            }
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onFirstAppear:
            return .task { 
                await .diaryLoadResponse(TaskResult { return try persistence.load() })
            }
            
        case .settingButtonTapped:
            return .send(.delegate(.settingButtonTapped))
            
        case .createButtonTapped:
            return .send(.delegate(.createButtonTapped))
            
        case .todayCardTapped:
            return .send(.delegate(.todayCardTapped))
            
        case .diaryCard:
            return .none
            
        case let .diaryLoadResponse(.success(diaries)):
            let diaryState: [DiaryCard.State] = diaries
                .map { diary in
                    return DiaryCard.State.init(
                        date: diary.date ?? .now, 
                        mood: DiaryMood(rawValue: diary.mood ?? "lucky") ?? .lucky, 
                        selectedImage: UIImage(data: diary.image ?? .init()), 
                        cardMode: .feed,
                        page: .photo,
                        content: diary.content ?? ""
                    )
                }
                .sorted { $0.date > $1.date }
            state.diaries = .init(uniqueElements: diaryState)
            return .none
            
        case .diaryLoadResponse(.failure):
            return .none
            
        case .delegate:
            return .none
        }
    }
}

extension DiaryFeed.State {
    mutating func insert(diary: DiaryCard.State) -> Effect<DiaryFeed.Action> {
        var feedDiary = diary
        feedDiary.cardMode = .feed
        feedDiary.page = .photo
        self.diaries.insert(feedDiary, at: .zero)
        return .none
    }
}

struct DiaryFeedView: View {
    let store: StoreOf<DiaryFeed>
    @ObservedObject var viewStore: ViewStore<ViewState, DiaryFeed.Action>
    
    struct ViewState: Equatable {
        let date: Date
        let diaries: IdentifiedArrayOf<DiaryCard.State>
        let isWrittenToday: Bool
        init(state: DiaryFeed.State) {
            self.date = state.date
            self.diaries = state.diaries
            self.isWrittenToday = state.diaries.isEmpty ? false : state.diaries.map(\.date).allSatisfy(\.isToday)
        }
    }
    
    init(store: StoreOf<DiaryFeed>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init)
    }
    
    var body: some View {
        bodyView
            .onFirstAppear { viewStore.send(.onFirstAppear) }
    }
    
    private var bodyView: some View {
        VStack(spacing: .zero) {
            navigationTitle
            
            ScrollView {
                Spacer().frame(height: 12)
                
                if viewStore.isWrittenToday == false {
                    emptyCardView
                        .padding(.horizontal, 20)
                        .onTapGesture {
                            viewStore.send(.createButtonTapped)
                        }
                }
                
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16, alignment: .top)]) {
                    ForEachStore(
                        store.scope(state: \.diaries, action: DiaryFeed.Action.diaryCard)
                    ) { store in
                        DiaryCardView(store: store)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var emptyCardView: some View {
        VStack(spacing: .zero) { 
            Spacer()
            Text(String(viewStore.date.day))
                .font(garamond: .hero)
                .foregroundColor(.text_disabled)
            
            Text(viewStore.date.weekday.english)
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
    }
    
    private var navigationTitle: some View {
        HStack(spacing: .zero) {
            Text(viewStore.date.dayroomMonth)
                .font(garamond: .heading2)
                .foregroundColor(.text_primary)
            
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
