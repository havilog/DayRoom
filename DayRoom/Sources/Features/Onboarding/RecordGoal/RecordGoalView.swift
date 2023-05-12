//
//  RecordGoalView.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/12.
//

import SwiftUI
import ComposableArchitecture

struct RecordGoalView: View {
    let store: StoreOf<RecordGoal>
    @ObservedObject var viewStore: ViewStoreOf<RecordGoal>
    
    init(store: StoreOf<RecordGoal>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        bodyView
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton)
    }
    
    private var bodyView: some View {
        VStack(spacing: .zero) { 
            VStack(alignment: .leading, spacing: .zero) { 
                title
                description
                
                // TODO: Chip GridView 구현
                
                if viewStore.goal == .custom {
                    customTextField
                        .padding(.top, 44)
                        .padding(.bottom, 16)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .debug(.red)
            .padding(.horizontal, 20)
            .debug(.red)
            
            Spacer()
            
            completeButton
                .padding(.bottom, 56)
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var backButton: some View {
        Button { viewStore.send(.backButtonTapped) } label: {
            Image("ic_chevron_left_ios_24")
                .frame(width: 48, height: 48)
                .debug()
        }
    }
    
    private var title: some View {
        Text("기록 목표가 무엇인가요?")
            .font(pretendard: .heading1)
            .foregroundColor(.text_primary)
            .debug()
    }
    
    private var description: some View {
        Text("마이페이지에서 언제든지 바꿀 수 있어요!")
            .font(pretendard: .body2)
            .foregroundColor(.text_secondary)
            .debug()
    }
    
    private var customTextField: some View {
        VStack(spacing: .zero) { 
            TextField("12자 이내 한글, 영문, 숫자", text: viewStore.binding(\.$custom))
                .foregroundColor(.text_primary)
                .font(pretendard: .heading3)
                .frame(maxHeight: 30)
//                .focused($focus, equals: .nickname)
                .disableAutocorrection(true)
                .debug()
                .padding(.bottom, 4)
            
            Rectangle()
                .foregroundColor(viewStore.isCustomValid ? .text_primary : .error)
                .frame(height: 1)
                .padding(.bottom, 4)
            
            HStack(spacing: .zero) {
                Text(viewStore.isCustomValid ? "" : "12자 이내 한글, 영문, 숫자로 작성해주세요.")
                    .font(pretendard: .caption)
                    .foregroundColor(.error)
                
                Spacer()
                
                Text("\(viewStore.custom.count) / 12")
                    .font(pretendard: .caption)
                    .foregroundColor(viewStore.isCustomValid ? .text_disabled : .error)
            }
        }
    }
    
    private var completeButton: some View {
        Button("완료") { viewStore.send(.completeButtonTapped) }
            .font(pretendard: .heading3)
            .foregroundColor(viewStore.isCompleteButtonDisabled ? Color.text_disabled : Color.day_white)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(viewStore.isCompleteButtonDisabled ? Color.grey20 : Color.day_green)
            .disabled(viewStore.isCompleteButtonDisabled)
            .debug()
    }
}

struct RecordGoalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RecordGoalView(
                store: .init(
                    initialState: .init(), 
                    reducer: RecordGoal()
                )
            )
        }
    }
}

