//
//  FeedFeature.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import SwiftUI
import Kingfisher
import ComposableArchitecture

struct Feed: Reducer {
    
    // MARK: State
    
    struct State: Hashable {
        var date: Date = .now
        var diaries: IdentifiedArrayOf<Diary> = .init()
    }
    
    // MARK: Action
    
    enum Action: Equatable {
        case onFirstAppear
        case settingButtonTapped
        case createButtonTapped
        case todayCardTapped
        case diaryCardTapped(Diary.ID)
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
            
        case let .diaryCardTapped(id):
            return .none
            
        case let .diaryLoadResponse(.success(diaries)):
            state.diaries = .init(uniqueElements: diaries)
            return .none
            
        case .diaryLoadResponse(.failure):
            return .none
            
        case .delegate:
            return .none
        }
    }
}

struct FeedView: View {
    let store: StoreOf<Feed>
    @ObservedObject var viewStore: ViewStore<ViewState, Feed.Action>
    
    struct ViewState: Equatable {
        let date: Date
        let diaries: IdentifiedArrayOf<Diary>
        let isWrittenToday: Bool
        init(state: Feed.State) {
            self.date = state.date
            self.diaries = state.diaries
            self.isWrittenToday = state.diaries.compactMap(\.date).allSatisfy(\.isToday)
        }
    }
    
    init(store: StoreOf<Feed>) {
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
                    CardView(date: viewStore.date, diaryMode: .photo(nil)) { 
                        viewStore.send(.todayCardTapped) 
                    }
                    .padding(.horizontal, 20)
                }
                
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16, alignment: .top)]) {
                    ForEach(viewStore.diaries) { diary in
                        // FIXME: 대충한거 고치기
                        CardView(date: diary.date!, diaryMode: .photo(UIImage(data: diary.image!))) {
                            viewStore.send(.diaryCardTapped(diary.id))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .debug(.red)
        }
        .ignoresSafeArea(edges: .bottom)
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
        .debug()
    }
}

enum DiaryMode: Equatable {
    case photo(UIImage?)
    case content(String)
}

struct CardView: View {
    let date: Date
    let diaryMode: DiaryMode
    
    var perform: () -> Void
    
    var body: some View {
        bodyView
    }
    
    @ViewBuilder
    private var bodyView: some View {
        switch diaryMode {
        case let .photo(uiImage):
            photoBody(uiImage)
            
        case let .content(content):
            Text(content)
        }
    }
    
    private func photoBody(_ image: UIImage?) -> some View {
        ZStack(alignment: .bottom) {
            photoContent(image)
                .frame(height: 500)
                .frame(maxWidth: .infinity)
                .cornerRadius(24)
                .contentShape(Rectangle())
                .onTapGesture(perform: perform)
            
            VStack(spacing: .zero) { 
                Text(String(date.day))
                    .font(garamond: .hero)
                    .foregroundColor(image == nil ? .text_disabled : .day_white)
                
                Text(date.weekday.english)
                    .font(garamond: .body2)
                    .foregroundColor(image == nil ? .text_disabled : .day_white)
            }
            .padding(24)
        }
    }
    
    @ViewBuilder
    private func photoContent(_ image: UIImage?) -> some View {
        if let image {
            Image(uiImage: image).resizable()
        } else {
            Color.elevated
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FeedView(
                store: .init(
                    initialState: .init(diaries: []), 
                    reducer: Feed()
                )
            )
        }
    }
}
