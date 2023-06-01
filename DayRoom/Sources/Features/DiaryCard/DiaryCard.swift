//
//  DiaryCard.swift
//  DayRoom
//
//  Created by 한상진 on 2023/06/01.
//

import SwiftUI

import ComposableArchitecture

struct DiaryCard: Reducer {
    
    // MARK: State
    
    struct State: Equatable {
        var date: Date
        var mood: DiaryMood
        var selectedImage: UIImage? = nil
        var content: String = ""
    }
    
    // MARK: Action
    
    enum Action: Equatable {
        
    }
    
    // MARK: Dependency
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
            
        }
    }
}

struct DiaryCardView: View {
    let store: StoreOf<DiaryCard>
    @ObservedObject var viewStore: ViewStore<ViewState, DiaryCard.Action>
    
    struct ViewState: Equatable {
        init(state: DiaryCard.State) {
            
        }
    }
    
    init(store: StoreOf<DiaryCard>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init)
    }
    
    var body: some View {
        Text("1234")
    }
}

enum DiaryMode: Equatable {
    case photo(UIImage?)
    case content(String)
}

struct CardView: View {
    /// diary를 받아서, 일기의 날짜를 표시해주고
    /// 액션을 인지하면, 토글
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


struct DiaryCardView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryCardView(
            store: .init(
                initialState: .init(date: .today, mood: .lucky), 
                reducer: DiaryCard()
            )
        )
    }
}

