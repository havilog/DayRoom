//
//  Password.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import SwiftUI
import ComposableArchitecture

struct Password: Reducer {
    
    // MARK: State
    
    struct State: Equatable {
        var mode: Mode
        var status: Status = .initial
        var informationText: String
        var inputPassword: String = ""
        @BindingState var isPasswordConformIncorrect: Bool = false
        
        init(mode: Mode) {
            self.mode = mode
            self.informationText = mode.description
        }
    }
    
    enum Password: Identifiable, Hashable {
        case first(Int)
        case second(Int)
        case third(Int)
        case forth(Int)
        var id: String {
            switch self {
            case .first: return "first"
            case .second: return "second"    
            case .third: return "third"    
            case .forth: return "forth"    
            }
        }
    }
    
    enum Mode: Equatable, CustomStringConvertible {
        case normal
        case change
        case new
        
        var description: String {
            switch self {
            case .normal: return "암호 입력"
            case .new: return "비밀번호를 입력해 주세요"
            case .change: return "새로운 비밀번호를 입력해 주세요"
            }
        }
    }
    
    enum Status: Equatable {
        case initial
        case confirm(enteredPassword: String)
    }
    
    // MARK: Action
    
    enum Action: Equatable, BindableAction {
        case closeButtonTapped
        case backButtonTapped
        case keypadTapped(number: String)
        
        case binding(BindingAction<State>)
        case delegate(Delegate)
        enum Delegate: Equatable {
            case passwordConfirmed
        }
    }
    
    // MARK: Dependency
    
    @Dependency(\.preferences) private var preferences
    @Dependency(\.dismiss) private var dismiss
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .closeButtonTapped:
            return .fireAndForget { await dismiss() }
            
        case .backButtonTapped:
            guard !state.inputPassword.isEmpty else { return .none }
            state.inputPassword.removeLast()
            return .none
            
        case let .keypadTapped(number):
            guard state.inputPassword.count < 4 else { return .none }
            
            state.inputPassword.append(number)
            
            if state.inputPassword.count == 4 {
                switch state.mode {
                case .normal:
                    guard state.inputPassword == preferences.password else {
                        state.isPasswordConformIncorrect = true
                        state.inputPassword.removeAll()
                        return .none
                    }
                    
                    return .send(.delegate(.passwordConfirmed), animation: .default)
                    
                case .new, .change:
                    guard case let .confirm(enteredPassword) = state.status else {
                        state.status = .confirm(enteredPassword: state.inputPassword)
                        state.informationText = "한 번 더 입력해주세요"
                        state.inputPassword.removeAll()
                        return .none 
                    }
                    
                    guard state.inputPassword == enteredPassword else {
                        state.isPasswordConformIncorrect = true
                        state.inputPassword.removeAll()
                        return .none
                    }
                    
                    preferences.password = enteredPassword
                    
                    return .merge(
                        .send(.delegate(.passwordConfirmed), animation: .default),
                        .fireAndForget { await dismiss() }
                    )
                }
            }
            
            return .none
            
        case .binding:
            return .none
            
        case .delegate:
            return .none
        }
    }
}

struct PasswordView: View {
    let store: StoreOf<Password>
    @ObservedObject var viewStore: ViewStoreOf<Password>
    
    init(store: StoreOf<Password>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
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
                title.padding(.bottom, 40)
                passwordClovers
                    .shake(viewStore.binding(\.$isPasswordConformIncorrect))
            }
            .padding(.bottom, 80)
            
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
                .foregroundColor(viewStore.inputPassword.count >= 1 ? .day_primary : .divider)
            Image("logo_dayroom_symbol")
                .renderingMode(.template)
                .foregroundColor(viewStore.inputPassword.count >= 2 ? .day_primary : .divider)
            Image("logo_dayroom_symbol")
                .renderingMode(.template)
                .foregroundColor(viewStore.inputPassword.count >= 3 ? .day_primary : .divider)
            Image("logo_dayroom_symbol")
                .renderingMode(.template)
                .foregroundColor(viewStore.inputPassword.count == 4 ? .day_primary : .divider)
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
                Button { viewStore.send(.backButtonTapped) } label: { 
                    Image("ic_delete_24").frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: 109, height: 88)
                .debug()
            }
        }
    }
    
    @ViewBuilder
    private func numberPad(_ number: Int?) -> some View {
        if let number {
            Button { viewStore.send(.keypadTapped(number: String(number))) } label: { 
                Text("\(number)")
                    .font(garamond: .heading1)
                    .foregroundColor(.text_primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: 109, height: 88)
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
