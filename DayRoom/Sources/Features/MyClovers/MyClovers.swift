//
//  MyClovers.swift
//  DayRoom
//
//  Created by 한상진 on 2023/06/24.
//

import SwiftUI
import ComposableArchitecture

// [[month: Int]]

struct MyClovers: Reducer {
    
    // MARK: State
    
    struct State: Equatable {
        let id: UUID = .init()
        let groupedDiaries: [(key: Date, value: Int)]
        
        init(diaries: IdentifiedArrayOf<DiaryCard.State>) {
            self.groupedDiaries = Dictionary(
                grouping: diaries, 
                by: Self.yearMonth
            )
            .mapValues(\.count)
            .sorted(by: { $0.key > $1.key })
        }
        
        private static func yearMonth(_ diary: DiaryCard.State) -> Date {
            let dateComponent = Calendar.current.dateComponents(
                [.year, .month], 
                from: diary.date
            )
            return Calendar.current.date(from: dateComponent)!
        }
        
        static func == (lhs: MyClovers.State, rhs: MyClovers.State) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    // MARK: Action
    
    enum Action: Equatable {
        case backButtonTapped
    }
    
    // MARK: Dependency
    
    @Dependency(\.dismiss) private var dismiss
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .backButtonTapped:
            return .run { _ in await dismiss() }
        }
    }
}


struct MyCloversView: View {
    let store: StoreOf<MyClovers>
    @ObservedObject var viewStore: ViewStoreOf<MyClovers>
    
    init(store: StoreOf<MyClovers>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        bodyView
            .navigationBarBackButtonHidden(true)
            .toolbar { 
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { viewStore.send(.backButtonTapped) } label: { 
                        Image("ic_chevron_left_ios_24")
                    }
                    .frame(width: 48, height: 48)
                }
            }
    }
    
    private var bodyView: some View {
        VStack(spacing: .zero) { 
            navigationTitle
                .padding(.top, 8)
                .padding(.horizontal, 20)
            
            cloverTabView(viewStore.groupedDiaries)
            
            Spacer()
        }
        .background(Color.elevated)
    }
    
    private var navigationTitle: some View {
        Text("내 클로버")
            .font(pretendard: .display1)
            .foregroundColor(.grey80)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func cloverTabView(_ groupedDiaries: [(key: Date, value: Int)]) -> some View {
        TabView {
            ForEach(groupedDiaries, id: \.key) { key, value in
                cloverCardView(
                    date: key, 
                    count: value
                )
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .flipsForRightToLeftLayoutDirection(true)
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    private func cloverCardView(date: Date, count: Int) -> some View {
        VStack(spacing: .zero) { 
            HStack(spacing: .zero) { 
                Text("\(date.dayroomMonth)")
                    .font(garamond: .heading4)
                    .foregroundColor(.text_secondary)
                Spacer()
                Text("\(count)")
                    .font(garamond: .heading4)
                    .foregroundColor(.text_secondary)
            }
            .padding(.top, 32)
            .padding(.horizontal, 40)
            .padding(.bottom, 56)
            
            cloverGrids(count: count)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.day_white)
        .cornerRadius(24)
        .padding(.horizontal, 32)
        .frame(height: (UIScreen.main.bounds.size.width - 64) * 1.389)
        .rotation3DEffect(.degrees(180), axis: (x: 0.0, y: 1.0, z: 0.0))
    }
    
    private func cloverGrids(count: Int) -> some View {
        let gridItems: [GridItem] = [
            GridItem(.fixed(36)),
            GridItem(.fixed(36)),
            GridItem(.fixed(36)),
            GridItem(.fixed(36)),
            GridItem(.fixed(36)),
        ]
        
        return LazyVGrid(columns: gridItems) {
            ForEach(0..<count, id: \.self) { index in
                Image("logo_dayroom_symbol")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .padding(.horizontal, 5)
                    .opacity(Int(index).opacity)
            }
        }
    }
}

private extension Int {
    var opacity: CGFloat {
        if self < 0 {
            return 0.0
        } else if self >= 0, self < 5 {
            return 0.5
        } else if self >= 5, self < 10 {
            return 0.6
        } else if self >= 10, self < 15 {
            return 0.7
        } else if self >= 15, self < 20 {
            return 0.8
        } else if self >= 20, self < 25 {
            return 0.9
        } else {
            return 1.0
        } 
    }
}

//private protocol _Int {}
//extension Int: _Int {}
//
//private extension CountableClosedRange where Bound: _Int {
//    static var opacity: CGFloat {
//        if self ~= 0...4 {
//            return 0.5
//        } else {
//            return 1.0
//        }
//    }
//}

struct MyCloversView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MyCloversView(
                store: .init(
                    initialState: .init(diaries: [
                        .init(date: .today, mood: .sad, cardMode: .create),
                        .init(date: .today.tomorrow, mood: .sad, cardMode: .create),
                        .init(date: .today.tomorrow.tomorrow, mood: .sad, cardMode: .create),
                        .init(date: .today.tomorrow.tomorrow.tomorrow, mood: .sad, cardMode: .create),
                        .init(date: .today.nextMonth, mood: .sad, cardMode: .create),
                        .init(date: .today.nextMonth.tomorrow, mood: .sad, cardMode: .create),
                        .init(date: .today.nextMonth.tomorrow.tomorrow, mood: .sad, cardMode: .create),
                        .init(date: .today.nextMonth.tomorrow.tomorrow.tomorrow, mood: .sad, cardMode: .create),
                    ]), 
                    reducer: MyClovers()
                )
            )
        }
    }
}
