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
    
    struct State: Equatable {
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
        case doneButtonTapped
        
        case binding(BindingAction<State>)
        case delegate(Delegate)
        enum Delegate: Equatable {
            case nicknameDetermined
        }
    }
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onAppear:
            state.focus = .nickname
            return .none
            
        case .doneButtonTapped:
            return .send(.delegate(.nicknameDetermined))
            
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
            VStack(alignment: .leading, spacing: .zero) {
                title
                description
                nicknameTextField
                Spacer()
            }
            .padding(.horizontal, 20)
            
            doneButton
        }
        .onAppear { viewStore.send(.onAppear) }
    }
    
    private var title: some View {
        Text("별명을 알려주세요")
            .font(pretendard: .heading1)
            .foregroundColor(.text_primary)
            .debug()
            .padding(.top, 56)
            .padding(.bottom, 4)
    }
    
    private var description: some View {
        Text("마이페이지에서 언제든지 바꿀 수 있어요!")
            .font(pretendard: .body2)
            .foregroundColor(.text_secondary)
            .debug()
            .padding(.bottom, 56)
    }
    
    private var nicknameTextField: some View {
        VStack(spacing: .zero) { 
            TextField("8자 이내 한글, 영문, 숫자", text: viewStore.binding(\.$nickname))
                .foregroundColor(.text_primary)
                .font(pretendard: .heading3)
                .frame(maxHeight: 30)
                .focused($focus, equals: .nickname)
                .disableAutocorrection(true)
                .debug()
                .padding(.bottom, 4)
            
            Rectangle()
                .foregroundColor(viewStore.isNicknameValid ? .text_primary : .error)
                .frame(height: 1)
                .padding(.bottom, 4)
            
            HStack(spacing: .zero) {
                Text(viewStore.isNicknameValid ? "" : "8자 이내 한글, 영문, 숫자로 작성해주세요.")
                    .font(pretendard: .caption)
                    .foregroundColor(.error)
                
                Spacer()
                
                Text("\(viewStore.nickname.count) / 8")
                    .font(pretendard: .caption)
                    .foregroundColor(viewStore.isNicknameValid ? .text_disabled : .error)
            }
        }
    }
    
    private var doneButton: some View {
        Button { viewStore.send(.doneButtonTapped) } label: { 
            Text("다음")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(pretendard: .heading3)
        }
        .foregroundColor(viewStore.isDoneButtonDisabled ? Color.text_disabled : Color.day_white)
        .frame(maxWidth: .infinity, maxHeight: 56)
        .background(viewStore.isDoneButtonDisabled ? Color.grey20 : Color.day_green)
        .disabled(viewStore.isDoneButtonDisabled)
        .debug()
    }
}

struct NicknameView_Previews: PreviewProvider {
    static var previews: some View {
        NicknameView(
            store: .init(
                initialState: .init(), 
                reducer: Nickname()
            )
        )
    }
}
