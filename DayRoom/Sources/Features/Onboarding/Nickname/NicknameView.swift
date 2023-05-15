//
//  NicknameView.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import SwiftUI
import ComposableArchitecture

struct NicknameView: View {
    let store: StoreOf<Nickname>
    @ObservedObject var viewStore: ViewStoreOf<Nickname>
    @FocusState var focus: Nickname.State.Field?
    
    init(store: StoreOf<Nickname>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        NavigationStackStore(
            store.scope(
                state: \.path, 
                action: Nickname.Action.path
            )
        ) { 
            bodyView
        } destination: { destination in
            switch destination {
            case .recordGoal:
                CaseLet(
                    state: /Nickname.Path.State.recordGoal, 
                    action: Nickname.Path.Action.recordGoal
                ) { store in
                    RecordGoalView(store: store)
                }
            }
        }
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
            
            nextButton
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
    
    private var nextButton: some View {
        Button { viewStore.send(.nextButtonTapped) } label: { 
            Text("다음")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(pretendard: .heading3)
        }
        .foregroundColor(viewStore.isNextButtonDisabled ? Color.text_disabled : Color.day_white)
        .frame(maxWidth: .infinity, maxHeight: 56)
        .background(viewStore.isNextButtonDisabled ? Color.grey20 : Color.day_green)
        .disabled(viewStore.isNextButtonDisabled)
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
