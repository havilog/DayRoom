//
//  NicknameFeature.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import SwiftUI
import Foundation
import ComposableArchitecture

struct Nickname: Reducer {
    
    // MARK: State
    
    enum NickNameMode {
        case onboarding
        case edit
    }
    
    struct State: Equatable {
        let mode: NickNameMode
        
        var isNicknameValid: Bool = true
        var isDoneButtonDisabled: Bool { !isNicknameValid || nickname.isEmpty }
        
        @BindingState var nickname: String = ""
        @BindingState var focus: Field?
        
        enum Field: String, Hashable {
            case nickname
        }
    }
    
    // MARK: Action
    
    enum Action: Equatable, BindableAction {
        case onAppear
        case keyboardWillBecomeFirstResponder
        case doneButtonTapped
        case cancelButtonTapped
        
        case binding(BindingAction<State>)
        case delegate(Delegate)
        enum Delegate: Equatable {
            case nicknameDetermined
        }
    }
    
    // MARK: Dependency
    
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.continuousClock) private var clock
    @Dependency(\.preferences) private var preferences
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onAppear:
            return .task { 
                try await self.clock.sleep(for: .seconds(0.1))
                return .keyboardWillBecomeFirstResponder
            }
            
        case .keyboardWillBecomeFirstResponder:
            state.focus = .nickname
            return .none
            
        case .doneButtonTapped:
            guard state.isNicknameValid else { return .none }
            preferences.nickname = state.nickname
            return .send(.delegate(.nicknameDetermined))
            
        case .cancelButtonTapped:
            return .run { _ in await self.dismiss() }
            
        case .binding(\.$nickname):
            state.isNicknameValid = validate(nickname: state.nickname)
            return .none
            
        case .binding:
            return .none
            
        case .delegate:
            return .none
        }
    }
    
    private func validate(nickname: String) -> Bool {
        let regex = "[가-힣ㄱ-ㅎㅏ-ㅣA-Za-z0-9]{0,8}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: nickname)
    }
}

struct NicknameView: View {
    let store: StoreOf<Nickname>
    @ObservedObject var viewStore: ViewStoreOf<Nickname>
    @FocusState var focus: Nickname.State.Field?
    
    init(store: StoreOf<Nickname>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        bodyView
    }
    
    private var bodyView: some View {
        VStack(spacing: .zero) { 
            if viewStore.mode == .edit {
                Button { viewStore.send(.cancelButtonTapped) } label: { 
                    Image("ic_cancel_24")
                }
                .frame(height: 44)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 22)
            } else {
                Color.clear.frame(height: 44)
            }
            
            Image("name_illust")
                .renderingMode(.original)
                .padding(.bottom, 40)
            
            VStack(alignment: .leading, spacing: .zero) {
                enterNicknameTitle
                    .padding(.bottom, 16)
                nicknameTextField
            }
            .padding(.horizontal, 20)
            Spacer()
            doneButton
        }
        .onAppear { viewStore.send(.onAppear) }
    }
    
    private var enterNicknameTitle: some View {
        Text("이름을 알려주세요.".localized)
            .font(pretendard: .heading1)
            .foregroundColor(.grey80)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var nicknameTextField: some View {
        TextField("8자 이내 한글, 영문, 숫자".localized, text: viewStore.binding(\.$nickname))
            .frame(height: 28)
            .foregroundColor(.text_primary)
            .font(pretendard: .heading3)
        
            .focused($focus, equals: .nickname)
            .disableAutocorrection(true)
        
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.divider, lineWidth: 1)
            )
    }
    
    private var doneButton: some View {
        Button { viewStore.send(.doneButtonTapped) } label: { 
            Text(viewStore.mode == .onboarding ? "시작하기".localized : "저장".localized)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(pretendard: .body1)
        }
        .foregroundColor(viewStore.isDoneButtonDisabled ? Color.text_disabled : Color.day_white)
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .background(viewStore.isDoneButtonDisabled ? Color.grey20 : Color.day_green)
        .disabled(viewStore.isDoneButtonDisabled)
    }
}

struct NicknameView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NicknameView(
                store: .init(
                    initialState: .init(mode: .edit), 
                    reducer: Nickname()
                )
            )
        }
    }
}
