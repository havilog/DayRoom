//
//  PasswordView.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import SwiftUI
import ComposableArchitecture

struct PasswordView: View {
    let store: StoreOf<Password>
    @ObservedObject var viewStore: ViewStore<ViewState, Password.Action>
    
    struct ViewState: Equatable {
        var mode: Password.Mode
        var informationText: String
        var isPasswordConformIncorrect: Bool
        var inputPasswordCount: Int
        
        init(state: Password.State) {
            self.mode = state.mode
            self.informationText = state.informationText
            self.isPasswordConformIncorrect = state.isPasswordConformIncorrect
            self.inputPasswordCount = state.inputPassword.count
        }
    }
    
    init(store: StoreOf<Password>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init)
    }
    
    var body: some View {
        bodyView
    }
    
    private var bodyView: some View {
        VStack(spacing: .zero) {
            navigationTitle
                .padding(.bottom, 56)
                .opacity(viewStore.mode == .normal ? 0 : 1)
            
            VStack(spacing: .zero) {
                VStack(spacing: .zero) { 
                    title
                    if viewStore.isPasswordConformIncorrect {
                        passwordIncorrectDescription
                            .padding(.top, 4)    
                    }
                }
                .padding(.bottom, 40)
                .debug()
                
                passwordClovers.debug()
            }
            .padding(.bottom, viewStore.isPasswordConformIncorrect ? 48 : 80)
            
            keypad
            
            Spacer()
        }
    }
    
    private var navigationTitle: some View {
        HStack(spacing: .zero) { 
            Button { viewStore.send(.closeButtonTapped) } label: { 
                Image("ic_cancel_24").frame(width: 48, height: 48)
            }
            .padding(.leading, 12)
            
            Spacer()
            
            Text("비밀번호 설정")
                .font(pretendard: .heading3)
                .foregroundColor(.text_primary)
            
            Spacer()
            
            Color.clear
                .frame(width: 48, height: 48)
                .padding(.trailing, 12)
        }
        .frame(height: 56)
        .debug()
    }
    
    private var title: some View {
        Text(viewStore.informationText)
            .font(pretendard: .heading2)
            .foregroundColor(.text_primary)
    }
    
    private var passwordIncorrectDescription: some View {
        Text("비밀번호가 일치하지 않습니다")
            .font(pretendard: .body2)
            .foregroundColor(.error)
    }
    
    private var passwordClovers: some View {
        HStack(spacing: 20) {
            Image("logo_dayroom_symbol")
                .renderingMode(.template)
                .foregroundColor(viewStore.inputPasswordCount >= 1 ? .day_primary : .divider)
            Image("logo_dayroom_symbol")
                .renderingMode(.template)
                .foregroundColor(viewStore.inputPasswordCount >= 2 ? .day_primary : .divider)
            Image("logo_dayroom_symbol")
                .renderingMode(.template)
                .foregroundColor(viewStore.inputPasswordCount >= 3 ? .day_primary : .divider)
            Image("logo_dayroom_symbol")
                .renderingMode(.template)
                .foregroundColor(viewStore.inputPasswordCount == 4 ? .day_primary : .divider)
        }
    }
    
    private var keypad: some View {
        Grid(horizontalSpacing: .zero, verticalSpacing: .zero) {
            GridRow { 
                ForEach(1..<4) { column in
                    numberPad(column)
                }
            }
            GridRow { 
                ForEach(4..<7) { column in
                    numberPad(column)
                }
            }
            GridRow { 
                ForEach(7..<10) { column in
                    numberPad(column)
                }
            }
            GridRow { 
                numberPad(nil)
                numberPad(0)
                Image("ic_delete_24")
                    .frame(width: 109, height: 88)
                    .contentShape(Rectangle())
                    .onTapGesture { viewStore.send(.backButtonTapped) }
                    .debug()
            }
        }
    }
    
    @ViewBuilder
    private func numberPad(_ number: Int?) -> some View {
        if let number {
            Text("\(number)")
                .font(garamond: .heading1)
                .foregroundColor(.text_primary)
                .frame(width: 109, height: 88)
                .contentShape(Rectangle())
                .onTapGesture { viewStore.send(.keypadTapped(number: String(number))) }
                .debug()
        } else {
            Color.clear
                .frame(width: 109, height: 88)
                .debug()
        }
    }
}

struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordView(
            store: .init(
                initialState: .init(mode: .new), 
                reducer: Password()
            )
        )
        
        PasswordView(
            store: .init(
                initialState: .init(mode: .change), 
                reducer: Password()
            )
        )    
        
        PasswordView(
            store: .init(
                initialState: .init(mode: .normal),
                reducer: Password()
            )
        )    
    }
}

