//
//  PasswordSetting.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/18.
//

import ComposableArchitecture

struct PasswordSetting: Reducer {
    
    // MARK: State
    
    struct State: Equatable {
        @BindingState var isUsingPassword: Bool
        @PresentationState var destination: Destination.State? = nil
    }
    
    // MARK: Action
    
    enum Action: Equatable, BindableAction {
        case backButtonTapped
        case changePasswordButtonTapped
        
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case delegate(Delegate)
        
        enum Delegate {
            case backButtonTapped
        }
    }
    
    // MARK: Destination
    
    struct Destination: Reducer {
        enum State: Equatable {
            case passwordChange(Password.State)
        }
        
        enum Action: Equatable {
            case passwordChage(Password.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.passwordChange, action: /Action.passwordChage) { 
                Password()
            }
        }
    }
    
    // MARK: Dependency
    
    @Dependency(\.preferences) private var preferences
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce(core)
            .ifLet(\.$destination, action: /Action.destination) { Destination() }
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .backButtonTapped:
            return .send(.delegate(.backButtonTapped))
            
        case .changePasswordButtonTapped:
            state.destination = .passwordChange(.init(mode: .change))
            return .none
            
        case .binding(\.$isUsingPassword):
            if state.isUsingPassword {
                state.destination = .passwordChange(.init(mode: .new))
            } else {
                preferences.password = nil
            }
            return .none
            
        case .binding:
            return .none
            
        case .destination(.dismiss):
            if preferences.password.isNil { 
                state.isUsingPassword = false 
            }
            return .none
            
        case .destination:
            return .none
            
        case .delegate:
            return .none
        }
    }
}

import SwiftUI
import ComposableArchitecture

struct PasswordSettingView: View {
    let store: StoreOf<PasswordSetting>
    @ObservedObject var viewStore: ViewStoreOf<PasswordSetting>
    
    init(store: StoreOf<PasswordSetting>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        bodyView
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { backButton }
                ToolbarItem(placement: .principal) { navigationTitle }
            }
            .sheet(
                store: store.scope(
                    state: \.$destination, 
                    action: PasswordSetting.Action.destination
                ),
                state: /PasswordSetting.Destination.State.passwordChange,
                action: PasswordSetting.Destination.Action.passwordChage,
                content: PasswordView.init
            )
    }
    
    private var backButton: some View {
        Button { viewStore.send(.backButtonTapped) } label: { 
            Image("ic_chevron_left_ios_24")
        }
        .frame(width: 48, height: 48)
    }
    
    private var navigationTitle: some View {
        Text("잠금")
            .font(pretendard: .heading3)
            .foregroundColor(.text_primary)
    }
    
    private var bodyView: some View {
        VStack(spacing: .zero) { 
            callOut
            passwordToggle
            passwordChange
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    private var callOut: some View {
        HStack(spacing: .zero) { 
            Image("ic_caution_fill_24")
                .padding(.leading, 16)
                .padding(.trailing, 8)
            Text("비밀번호를 분실하면 찾을 수 없어요")
                .font(pretendard: .body4)
                .foregroundColor(.text_secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .background(Color.elevated)
        .cornerRadius(6)
        .padding(.vertical, 16)
    }
    
    private var passwordToggle: some View {
        Toggle(isOn: viewStore.binding(\.$isUsingPassword)) { 
            Text("비밀번호 사용")
                .font(pretendard: .heading4)
                .foregroundColor(.text_primary)
                .frame(maxWidth: .infinity, maxHeight: 54, alignment: .leading)
        }
    }
    
    private var passwordChange: some View {
        Button { viewStore.send(.changePasswordButtonTapped) } label: { 
            Text("비밀번호 변경")
                .font(pretendard: .heading4)
                .foregroundColor(viewStore.isUsingPassword ? .text_primary : .text_disabled)
                .frame(maxWidth: .infinity, maxHeight: 54, alignment: .leading)
        }
        .disabled(!viewStore.isUsingPassword)
    }
}

struct PasswordSettingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PasswordSettingView(
                store: .init(
                    initialState: .init(isUsingPassword: false), 
                    reducer: PasswordSetting()
                )
            )    
        }
    }
}

