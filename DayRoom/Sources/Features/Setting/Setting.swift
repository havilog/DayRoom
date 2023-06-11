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
    
    struct State: Hashable {
        var appVersion: String = Bundle.main.releaseVersionNumber ?? "1.0.0"
        var isUsingPassword: Bool
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
        
        var description: String {
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
        case settingRowTapped(Row)
        case delegate(Delegate)
        enum Delegate: Equatable {
            case settingRowTapped(Row) 
            case backButtonTapped
        }
    }
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .backButtonTapped:
            return .send(.delegate(.backButtonTapped))
            
        case let .settingRowTapped(row):
            return .send(.delegate(.settingRowTapped(row)))
            
        case .delegate:
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
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
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
                Text("하진") // 내 닉네임
                    .padding(.trailing, 8)
                Button { } label: { 
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
            settingRow(.version) {
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
        trailingView: () -> some View = { EmptyView() }
    ) -> some View {
        Button { viewStore.send(.settingRowTapped(settingRow)) } label: { 
            HStack(spacing: .zero) { 
                Image(settingRow.iconName)
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 8)
                
                Text("\(settingRow.description)")
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
                    initialState: .init(isUsingPassword: false), 
                    reducer: Setting()
                )
            )
        }
    }
}
