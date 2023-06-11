//
//  Setting.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/14.
//

import SwiftUI
import ComposableArchitecture

struct Setting: Reducer {
    
    // MARK: State
    
    struct State: Equatable {
        var appVersion: String = Bundle.main.releaseVersionNumber ?? "1.0.0"
        var nickname: String
        var isUsingPassword: Bool
        @PresentationState var destination: Destination.State? = nil
    }
    
    enum Row: Equatable {
        case lock
        case whoMadeThis
        case version
        
        var iconName: String {
            switch self {
            case .lock: return "ic_lock_24"
            case .whoMadeThis: return "ic_user_24"
            case .version: return "ic_info_24"
            }
        }
        
        var title: String {
            switch self {
            case .lock: return "잠금"
            case .whoMadeThis: return "만든 사람들"
            case .version: return "버전 정보"
            }
        }
    } 
    
    // MARK: Action
    
    enum Action: Equatable {
        case backButtonTapped
        case changeNicknameButtonTapped
        case myCloverButtonTapped
        case settingRowTapped(Row)
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)
        enum Delegate: Equatable {
            case backButtonTapped
            case settingRowTapped(Row)
            case myCloverButtonTapped
        }
    }
    
    // MARK: Destination
    
    struct Destination: Reducer {
        enum State: Equatable {
            case nickname(Nickname.State)
        }
        
        enum Action: Equatable {
            case nickname(Nickname.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.nickname, action: /Action.nickname) { 
                Nickname()
            }
        }
    }
    
    // MARK: Dependency
    
    @Dependency(\.preferences) private var preferences 
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Reduce(core)
            .ifLet(\.$destination, action: /Action.destination) { Destination() }
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .backButtonTapped:
            return .send(.delegate(.backButtonTapped))
            
        case .changeNicknameButtonTapped:
            state.destination = .nickname(.init())
            return .none
            
        case .myCloverButtonTapped:
            return .none
            
        case let .settingRowTapped(row):
            return .send(.delegate(.settingRowTapped(row)))
            
        case .delegate:
            return .none
            
        case .destination(.presented(.nickname(.delegate(.nicknameDetermined)))):
            state.nickname = preferences.nickname ?? ""
            state.destination = nil
            return .none
            
        case .destination:
            return .none
        }
    }
}

struct SettingView: View {
    let store: StoreOf<Setting>
    @ObservedObject var viewStore: ViewStoreOf<Setting>
    
    init(store: StoreOf<Setting>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        bodyView
            .navigationBarBackButtonHidden(true)
            .sheet(
                store: store.scope(state: \.$destination, action: Setting.Action.destination),
                state: /Setting.Destination.State.nickname,
                action: Setting.Destination.Action.nickname,
                content: NicknameView.init
            )
            .toolbar { 
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { viewStore.send(.backButtonTapped) } label: { 
                        Image("ic_chevron_left_ios_24")
                    }
                    .frame(width: 48, height: 48)
                }
                ToolbarItem(placement: .principal) {
                    Text("마이페이지")
                        .font(pretendard: .heading3)
                        .foregroundColor(.text_primary)
                }
            }
    }
    
    private var bodyView: some View {
        ScrollView {
            VStack(spacing: .zero) { 
                myInfoView
                settingSection
                appInfoSection
            }
            .padding(.top, 16)
        }
        .padding(.horizontal, 20)
    } 
    
    private var myInfoView: some View {
        VStack(alignment: .leading, spacing: .zero) {
            HStack(spacing: .zero) {
                Text(viewStore.nickname)
                    .padding(.trailing, 8)
                Button { viewStore.send(.changeNicknameButtonTapped) } label: { 
                    Image("ic_edit_fill_24")
                }

            }
            .padding([.top, .horizontal], 16)
            
            Divider()
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            
            Button { } label: { 
                HStack(spacing: .zero) { 
                    Text("내 클로버")
                        .font(pretendard: .body2)
                        .foregroundColor(.text_primary)
                        .padding(.trailing, 8)
                    Text("22개") // 내 클로버 갯수
                        .font(pretendard: .body1)
                        .foregroundColor(.text_primary)
                    Spacer()
                    Image("ic_chevron_right_24").frame(width: 24, height: 24)
                }
            }
            .padding([.bottom, .horizontal], 16)
        }
        .background(Color.elevated)
        .cornerRadius(12)
        .padding(.bottom, 12)
    }
    
    private var settingSection: some View {
        Section { 
            settingRow(.lock, hasTrailingArrow: true) {
                Text("\(viewStore.isUsingPassword ? "ON" : "OFF")")
                    .font(pretendard: .body2)
                    .foregroundColor(.text_primary)
            }
        } header: { 
            sectionHeader("설정")
        } footer: { 
            sectionFooter
        }
    }
    
    private var appInfoSection: some View {
        Section {
            settingRow(.whoMadeThis)
            settingRow(.version, disableInteraction: true) {
                Text("v \(viewStore.appVersion)")
                    .font(pretendard: .body2)
                    .foregroundColor(.text_primary)
            }
        } header: { 
            sectionHeader("앱 정보")
        }
    }
    
    private func settingRow(
        _ settingRow: Setting.Row,
        hasTrailingArrow: Bool = false,
        disableInteraction: Bool = false,
        trailingView: () -> some View = { EmptyView() }
    ) -> some View {
        Button { viewStore.send(.settingRowTapped(settingRow)) } label: { 
            HStack(spacing: .zero) { 
                Image(settingRow.iconName)
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 8)
                
                Text("\(settingRow.title)")
                    .font(pretendard: .heading4)
                    .foregroundColor(.text_primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding(.trailing, 8)
                
                trailingView()
                
                if hasTrailingArrow {
                    Image("ic_chevron_right_24").frame(width: 24, height: 24)
                        .padding(.leading, 4)
                }
            }
        }
        .disabled(disableInteraction)
        .frame(height: 54)
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text("\(title)")
            .font(pretendard: .body2)
            .foregroundColor(.text_primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 4)
    }
    
    private var sectionFooter: some View {
        Divider()
            .frame(maxWidth: .infinity, maxHeight: 1)
            .background(Color.divider)
            .padding(.vertical, 10)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingView(
                store: .init(
                    initialState: .init(nickname: "havi", isUsingPassword: false), 
                    reducer: Setting()
                )
            )
        }
    }
}
