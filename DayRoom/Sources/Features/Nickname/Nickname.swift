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
            cloverWithMailImage
            VStack(alignment: .leading, spacing: .zero) {
                title
                nicknameTextField
            }
            .padding(.horizontal, 20)
            Spacer()
            doneButton
        }
        .onAppear { viewStore.send(.onAppear) }
    }
    
    private var cloverWithMailImage: some View {
        Image("name_illust")
            .padding(.top, 48)
            .padding(.bottom, 44)
    }
    
    private var title: some View {
        Text("기록가님 반가워요!")
            .font(pretendard: .heading2)
            .foregroundColor(.text_primary)
            .debug()
            .padding(.bottom, 16)
    }
    
    private var nicknameTextField: some View {
        TextField("8자 이내 한글, 영문, 숫자", text: viewStore.binding(\.$nickname))
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
            Text("시작하기")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(pretendard: .body1)
        }
        .foregroundColor(viewStore.isDoneButtonDisabled ? Color.text_disabled : Color.day_white)
        .frame(height: 52)
        .frame(maxWidth: .infinity)
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
