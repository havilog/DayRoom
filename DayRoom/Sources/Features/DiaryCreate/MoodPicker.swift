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
            VStack(spacing: .zero) {
                moodView(mood: .lucky) { 
                    viewStore.send(.moodSelected(.lucky))
                }
                .offset(y: 80)
                
                moodView(mood: .happy) { 
                    viewStore.send(.moodSelected(.happy))
                }
                .offset(y: 60)
                
                moodView(mood: .soso) { 
                    viewStore.send(.moodSelected(.soso))
                }
                .offset(y: 40)
                
                moodView(mood: .angry) { 
                    viewStore.send(.moodSelected(.angry))
                }
                .offset(y: 20)
                
                moodView(mood: .sad) { 
                    viewStore.send(.moodSelected(.sad))
                }
                .offset(y: 0)
            }
            .presentationDetents([.height(450)])
            .presentationCornerRadius(24)
            .ignoresSafeArea()
            .offset(y: -20)
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
                .offset(y: -20)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
        .frame(maxWidth: .infinity)
        .frame(height: mood == .sad ? 130 : 110)
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

