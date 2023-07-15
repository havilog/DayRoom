//
//  MoodPicker.swift
//  DayRoom
//
//  Created by 한상진 on 2023/06/01.
//

import SwiftUI
import ComposableArchitecture

struct MoodPicker: Reducer {
    
    // MARK: State
    
    struct State: Equatable { }
    
    // MARK: Action
    
    enum Action: Equatable {
        case moodSelected(DiaryMood)
        case delegate(Delegate)
        enum Delegate: Equatable {
            case moodSelected(DiaryMood) 
        }
    }
    
    // MARK: Dependency
    
    @Dependency(\.dismiss) private var dismiss
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .moodSelected(mood):
            return .concatenate(
                .send(.delegate(.moodSelected(mood))),
                .run { _ in await dismiss() }
            )
            
        case .delegate:
            return .none
        }
    }
}


struct MoodPickerView: View {
    let store: StoreOf<MoodPicker>
    
    init(store: StoreOf<MoodPicker>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                ForEach(DiaryMood.allCases) { mood in
                    moodView(mood: mood) { 
                        viewStore.send(.moodSelected(mood))
                    }
                    .padding(.top, mood.index * 90)
                }
            }
            .presentationDetents([.height(450)])
            .presentationCornerRadius(24)
            .ignoresSafeArea()
            .background(Image("img_sad")) // 스유 버그인듯?
        }
    }
    
    private func moodView(
        mood: DiaryMood, 
        perform action: @escaping () -> Void
    ) -> some View {
        ZStack {
            Image(mood.imageName)
                .resizable()
            Text(mood.title)
                .font(garamond: .heading3)
                .foregroundColor(mood.foregroundColor)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 20)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(radius: 24, corners: [.topLeft, .topRight])
    }
}

struct MoodPickerView_Previews: PreviewProvider {
    static var previews: some View {
        MoodPickerView(
            store: .init(
                initialState: .init(), 
                reducer: MoodPicker()
            )
        )
    }
}

