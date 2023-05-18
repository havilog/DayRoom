//
//  RecordGoal.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import SwiftUI
import Foundation
import ComposableArchitecture

struct RecordGoal: Reducer {
    
    // MARK: State
    
    struct State: Hashable {
        var isCustomValid: Bool = true
        var isCompleteButtonDisabled: Bool {
            if let goal {
                switch goal {
                case .custom: return !isCustomValid || custom.isEmpty
                default: return false
                }    
            } else { return true }
        }
        
        @BindingState var custom: String = ""
        @BindingState var goal: Goal?
    }
    
    enum Goal: Hashable {
        case everytime
        case memory
        case daily
        case emotion
        case longliving
        case custom
        
        var description: String {
            switch self {
            case .everytime: return "모든 순간을 기록하기"
            case .memory: return "추억을 간직하기"
            case .daily: return "일상을 기록하기"
            case .emotion: return "감정을 기록하기"
            case .longliving: return "오랫동안 기억하기"
            case .custom: return "직접 입력하기"
            }
        }
    }
    
    // MARK: Action
    
    enum Action: Equatable, BindableAction {
        case backButtonTapped
        case completeButtonTapped
        case goalTapped(Goal)
        
        case delegate(Delegate)
        case binding(BindingAction<State>)
        
        enum Delegate {
            case backButtonTapped
            case completeButtonTapped
        }
    }
    
    // MARK: Dependency
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .binding(\.$custom):
            if state.custom.isEmpty {
                state.isCustomValid = true
            } else {
                state.isCustomValid = validate(custom: state.custom)
            }
            return .none
            
        case .binding:
            return .none
            
        case .delegate:
            return .none
            
        case .backButtonTapped:
            return .send(.delegate(.backButtonTapped))
            
        case .completeButtonTapped:
            // 코어데이터에 유저 정보 저장
            return .send(.delegate(.completeButtonTapped))
            
        case let .goalTapped(goal):
            state.goal = goal
            return .none
        }
    }
    
    private func validate(custom: String) -> Bool {
        let regex = "[가-힣ㄱ-ㅎㅏ-ㅣA-Za-z0-9]{0,12}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: custom)
    }
}

struct RecordGoalView: View {
    let store: StoreOf<RecordGoal>
    @ObservedObject var viewStore: ViewStoreOf<RecordGoal>
    
    init(store: StoreOf<RecordGoal>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        bodyView
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { 
                    backButton
                        .frame(height: 56)
                        .debug(.green)
                }
            }
    }
    
    private var bodyView: some View {
        VStack(spacing: .zero) { 
            VStack(alignment: .leading, spacing: .zero) { 
                title
                description.padding(.bottom, 20)
                goalGrid
                
                if viewStore.goal == .custom {
                    customTextField
                        .padding(.top, 44)
                        .padding(.bottom, 16)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .debug(.red)
            .padding(.horizontal, 20)
            
            Spacer()
            
            completeButton
                .padding(.bottom, 56)
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var backButton: some View {
        Button { viewStore.send(.backButtonTapped) } label: {
            Image("ic_chevron_left_ios_24")
                .frame(width: 48, height: 48)
                .debug()
        }
    }
    
    private var title: some View {
        Text("기록 목표가 무엇인가요?")
            .font(pretendard: .heading1)
            .foregroundColor(.text_primary)
            .debug()
    }
    
    private var description: some View {
        Text("마이페이지에서 언제든지 바꿀 수 있어요!")
            .font(pretendard: .body2)
            .foregroundColor(.text_secondary)
            .debug()
    }
    
    private var goalGrid: some View {
        VStack(alignment: .leading, spacing: 12) { 
            HStack(spacing: 8) { 
                goalItem(.everytime)
                goalItem(.memory)
            }
            HStack(spacing: 8) { 
                goalItem(.daily)
                goalItem(.emotion)
            }
            HStack(spacing: 8) { 
                goalItem(.longliving)
                goalItem(.custom)
            }
        }
    }
    
    private func goalItem(_ goal: RecordGoal.Goal) -> some View {
        Button { viewStore.send(.goalTapped(goal)) } label: { 
            Text("\(goal.description)")
                .font(pretendard: .body2)
                .foregroundColor(viewStore.goal == goal ? .day_green : .text_primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .overlay { 
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            viewStore.goal == goal ? Color.day_green : Color.divider, 
                            lineWidth: 1
                        )
                }
        }
        .background(viewStore.goal == goal ? Color.day_green_background : Color.day_white)
    }
    
    private var customTextField: some View {
        VStack(spacing: .zero) { 
            TextField("12자 이내 한글, 영문, 숫자", text: viewStore.binding(\.$custom))
                .foregroundColor(.text_primary)
                .font(pretendard: .heading3)
                .frame(maxHeight: 30)
//                .focused($focus, equals: .nickname)
                .disableAutocorrection(true)
                .debug()
                .padding(.bottom, 4)
            
            Rectangle()
                .foregroundColor(viewStore.isCustomValid ? .text_primary : .error)
                .frame(height: 1)
                .padding(.bottom, 4)
            
            HStack(spacing: .zero) {
                Text(viewStore.isCustomValid ? "" : "12자 이내 한글, 영문, 숫자로 작성해주세요.")
                    .font(pretendard: .caption)
                    .foregroundColor(.error)
                
                Spacer()
                
                Text("\(viewStore.custom.count) / 12")
                    .font(pretendard: .caption)
                    .foregroundColor(viewStore.isCustomValid ? .text_disabled : .error)
            }
        }
    }
    
    private var completeButton: some View {
        Button { viewStore.send(.completeButtonTapped) } label: {
            Text("완료")
                .font(pretendard: .heading3)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .foregroundColor(viewStore.isCompleteButtonDisabled ? Color.text_disabled : Color.day_white)
        .frame(maxWidth: .infinity, maxHeight: 56)
        .background(viewStore.isCompleteButtonDisabled ? Color.grey20 : Color.day_green)
        .disabled(viewStore.isCompleteButtonDisabled)
        .debug()
    }
}

struct RecordGoalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RecordGoalView(
                store: .init(
                    initialState: .init(), 
                    reducer: RecordGoal()
                )
            )
        }
    }
}

