//
//  SettingView.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/08.
//

import SwiftUI
import ComposableArchitecture

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
            settingRow(imageName: "ic_user_24", text: "잠금", hasTrailingArrow: true) {
                Text("OFF")
                    .font(pretendard: .body2)
                    .foregroundColor(.text_primary)
            }
            .debug(.red)
            
            settingRow(imageName: "ic_user_24", text: "잠금").debug(.red)
        } header: { 
            sectionHeader("설정")
        } footer: { 
            sectionFooter
        }
    }
    
    private var dataSection: some View {
        Section { 
            settingRow(imageName: "ic_user_24", text: "백업", hasTrailingArrow: true).debug(.red)
        } header: { 
            sectionHeader("데이터")
        } footer: { 
            sectionFooter
        }
    }
    
    private var appInfoSection: some View {
        Section { 
            settingRow(imageName: "ic_user_24", text: "백업", hasTrailingArrow: true).debug(.red)
        } header: { 
            sectionHeader("앱 정보")
        } footer: { 
            sectionFooter
        }
    }
    private var resetRow: some View {
        HStack(spacing: .zero) { 
            Image("ic_user_24")
                .renderingMode(.template)
                .foregroundColor(.error)
                .frame(width: 24, height: 24)
                .debug()
                .padding(.trailing, 8)
            
            Text("모든 기록 초기화")
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
        imageName: String, 
        text: String,
        hasTrailingArrow: Bool = false,
        trailingView: () -> some View = { EmptyView() }
    ) -> some View {
        HStack(spacing: .zero) { 
            Image(imageName)
                .frame(width: 24, height: 24)
                .debug()
                .padding(.trailing, 8)
            
            Text("\(text)")
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
        .frame(height: 54)
        .contentShape(Rectangle())
        .onTapGesture {
            // row ++
        }
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
