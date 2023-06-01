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
                .fireAndForget { await dismiss() }
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
            VStack(spacing: .zero) { 
                ForEach(DiaryMood.allCases) { mood in
                    Button { viewStore.send(.moodSelected(mood)) } label: { 
                        Text(mood.title)
                            .foregroundColor(.black)
                            .frame(height: 110)
                    }
                    .frame(maxWidth: .infinity)
                    .background(mood.backgroundColor)
                    .cornerRadius(radius: 24, corners: [.topLeft, .topRight])
                    .debug()
                }
            }
            .ignoresSafeArea()
            .presentationDetents([.height(450)])
            .interactiveDismissDisabled()
        }
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

