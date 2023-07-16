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
            case .normal: return "암호 입력".localized
            case .new: return "비밀번호를 입력해 주세요".localized
            case .change: return "새로운 비밀번호를 입력해 주세요".localized
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
        case deleteButtonTapped
        case keypadTapped(number: String)
        
        case binding(BindingAction<State>)
        case delegate(Delegate)
        enum Delegate: Equatable {
            case passwordConfirmed
        }
    }
    
    // MARK: Dependency
    
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.keychain) private var keychain
    @Dependency(\.feedbackGenerator) private var feedbackGenerator
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .closeButtonTapped:
            return .run { _ in await dismiss() }
            
        case .deleteButtonTapped:
            guard !state.inputPassword.isEmpty else { return .none }
            state.inputPassword.removeLast()
            return .none
            
        case let .keypadTapped(number):
            guard state.inputPassword.count < 4 else { return .none }
            
            state.inputPassword.append(number)
            
            if state.inputPassword.count == 4 {
                switch state.mode {
                case .normal:
                    guard state.inputPassword == keychain.getString(.password) else {
                        state.isPasswordConformIncorrect = true
                        state.inputPassword.removeAll()
                        return .run { _ in await feedbackGenerator.impact(.heavy) }
                    }
                    
                    return .send(.delegate(.passwordConfirmed), animation: .default)
                    
                case .new, .change:
                    guard case let .confirm(enteredPassword) = state.status else {
                        state.status = .confirm(enteredPassword: state.inputPassword)
                        state.informationText = "한 번 더 입력해주세요".localized
                        state.inputPassword.removeAll()
                        return .none 
                    }
                    
                    guard state.inputPassword == enteredPassword else {
                        state.isPasswordConformIncorrect = true
                        state.inputPassword.removeAll()
                        return .run { _ in await feedbackGenerator.impact(.heavy) }
                    }
                    
                    keychain.delete(.password)
                    keychain.set(enteredPassword, forKey: .password) 
                    
                    return .merge(
                        .send(.delegate(.passwordConfirmed), animation: .default),
                        .run { _ in await dismiss() }
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
            
            Spacer()
            
            keypad
            
            Spacer().frame(height: 60)
        }
    }
    
    private var navigationTitle: some View {
        HStack(spacing: .zero) { 
            Button { viewStore.send(.closeButtonTapped) } label: { 
                Image("ic_cancel_24").frame(width: 48, height: 48)
            }
            .padding(.leading, 12)
            
            Spacer()
            
            Text(viewStore.mode == .change ? "비밀번호 변경".localized : "비밀번호 설정".localized)
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
        Text("비밀번호가 일치하지 않습니다".localized)
            .font(pretendard: .body2)
            .foregroundColor(.error)
    }
    
    private var passwordClovers: some View {
        HStack(spacing: 20) {
            Image("logo_dayroom_symbol")
                .renderingMode(.template)
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(viewStore.inputPassword.count >= 1 ? .day_green : .divider)
            Image("logo_dayroom_symbol")
                .renderingMode(.template)
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(viewStore.inputPassword.count >= 2 ? .day_green : .divider)
            Image("logo_dayroom_symbol")
                .renderingMode(.template)
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(viewStore.inputPassword.count >= 3 ? .day_green : .divider)
            Image("logo_dayroom_symbol")
                .renderingMode(.template)
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(viewStore.inputPassword.count == 4 ? .day_green : .divider)
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
                Button { viewStore.send(.deleteButtonTapped) } label: { 
                    Image("ic_delete_24").frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: 109, height: 88)
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
        } else {
            Color.clear
                .frame(width: 109, height: 88)
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
