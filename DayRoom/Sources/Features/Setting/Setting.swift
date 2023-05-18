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
        
    }
    
    enum Row: Equatable, CustomStringConvertible {
        case lock
        case notification
        case style
        case backup
        case guide
        case version
        case reset
        
        var iconName: String {
            switch self {
            case .lock: return "ic_user_24"
            case .notification: return "ic_user_24"
            case .style: return "ic_user_24"
            case .backup: return "ic_user_24"
            case .guide: return "ic_user_24"
            case .version: return "ic_user_24"
            case .reset: return "ic_user_24" 
            }
        }
        
        var description: String {
            switch self {
            case .lock: return "설정"
            case .notification: return "잠금"
            case .style: return "화면 스타일"
            case .backup: return "백업"
            case .guide: return "데이룸 사용 가이드"
            case .version: return "버전 정보"
            case .reset: return "모든 기록 초기화" 
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
    
    // MARK: Dependency
    
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
    @ObservedObject var viewStore: ViewStore<ViewState, Setting.Action>
    
    struct ViewState: Equatable {
        init(state: Setting.State) {
            
        }
    }
    
    init(store: StoreOf<Setting>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init)
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
                    Text("설정")
                        .font(pretendard: .heading3)
                        .foregroundColor(.text_primary)
                        .frame(height: 56)
                        .debug()
                }
            }
    }
    
    private var bodyView: some View {
        ScrollView {
            VStack(spacing: .zero) { 
                settingSection
                dataSection
                appInfoSection
                resetRow
            }
            .padding(.top, 16)
        }
        .padding(.horizontal, 20)
    } 
    
    private var settingSection: some View {
        Section { 
            settingRow(.lock, hasTrailingArrow: true) {
                Text("OFF")
                    .font(pretendard: .body2)
                    .foregroundColor(.text_primary)
            }
            .debug(.red)
            
            settingRow(.notification, hasTrailingArrow: true).debug(.red)
            settingRow(.notification, hasTrailingArrow: true) {
                Text("시스템 모드")
                    .font(pretendard: .body2)
                    .foregroundColor(.text_primary)
            }
        } header: { 
            sectionHeader("설정")
        } footer: { 
            sectionFooter
        }
    }
    
    private var dataSection: some View {
        Section { 
            settingRow(.backup, hasTrailingArrow: true).debug(.red)
        } header: { 
            sectionHeader("데이터")
        } footer: { 
            sectionFooter
        }
    }
    
    private var appInfoSection: some View {
        Section { 
            settingRow(.guide).debug(.red)
        } header: { 
            sectionHeader("앱 정보")
        } footer: { 
            sectionFooter
        }
    }
    
    private var resetRow: some View {
        HStack(spacing: .zero) { 
            Image(Setting.Row.reset.iconName)
                .renderingMode(.template)
                .foregroundColor(.error)
                .frame(width: 24, height: 24)
                .debug()
                .padding(.trailing, 8)
            
            Text(Setting.Row.reset.description)
                .font(pretendard: .heading4)
                .foregroundColor(.error)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .debug()
                .padding(.trailing, 8)
        }
        .frame(height: 54)
        .debug(.red)
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
                    .debug()
                    .padding(.trailing, 8)
                
                Text("\(settingRow.description)")
                    .font(pretendard: .heading4)
                    .foregroundColor(.text_primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .debug()
                    .padding(.trailing, 8)
                
                trailingView()
                    .debug()
                
                // TODO: right arrow
                if hasTrailingArrow {
                    Image("ic_chevron_left_ios_24").frame(width: 24, height: 24)
                        .debug()    
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
            .debug(.yellow)
    }
    
    private var sectionFooter: some View {
        Divider()
            .frame(maxWidth: .infinity, maxHeight: 1)
            .background(Color.divider)
            .padding(.vertical, 20)
            .debug(.green)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingView(
                store: .init(
                    initialState: .init(), 
                    reducer: Setting()
                )
            )
        }
    }
}
