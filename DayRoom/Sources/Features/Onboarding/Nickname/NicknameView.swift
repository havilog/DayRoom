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
    @FocusState var focusedField: Nickname.State.Field?
    
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
                    Text("기록 목표가 무엇인가요?")
                }
            }
        }

        Text("")
    }
    
    var bodyView: some View {
        VStack(alignment: .leading, spacing: .zero) {
            Text("별명을 알려주세요")
                .padding(.top, 56)
                .padding(.bottom, 4)
            
            Text("마이페이지에서 언제든지 바꿀 수 있어요!")
                .padding(.bottom, 56)
            
            VStack(spacing: .zero) { 
                TextField("8자 이내 한글, 영문, 숫자", text: viewStore.binding(\.$nickname))
                    .focused($focusedField, equals: .nickname)
                    .disableAutocorrection(true)
                    .padding(.bottom, 4)
                
                Rectangle()
                    .background(Color.primary)
                    .frame(height: 1)
                    .padding(.bottom, 4)
                
                HStack(spacing: .zero) {
                    Text("8자 이내 한글, 영문, 숫자로 작성해주세요.")
                    
                    Spacer()
                    
                    Text("0 / 8")
                }
            }
            
            Spacer()
            
            Button("다음") { viewStore.send(.nextButtonTapped) }
        }
        .padding(.horizontal, 20)
    }
}

extension View {
    func synchronize<Value>(
        _ first: Binding<Value>,
        _ second: FocusState<Value>.Binding
    ) -> some View {
        self
            .onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
            .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
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
