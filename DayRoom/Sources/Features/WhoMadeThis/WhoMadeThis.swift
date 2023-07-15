//
//  WhoMadeThis.swift
//  DayRoom
//
//  Created by 한상진 on 2023/06/11.
//

import SwiftUI
import ComposableArchitecture

struct WhoMadeThis: Reducer {
    
    // MARK: State
    
    struct State: Equatable {
        
    }
    
    // MARK: Action
    
    enum Action: Equatable {
        case backButtonTapped
    }
    
    // MARK: Dependency
    
    @Dependency(\.dismiss) private var dismiss
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .backButtonTapped:
            return .run { _ in await dismiss() }
        }
    }
}

struct WhoMadeThisView: View {
    let store: StoreOf<WhoMadeThis>
    @ObservedObject var viewStore: ViewStoreOf<WhoMadeThis>
    
    init(store: StoreOf<WhoMadeThis>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        bodyView
            .navigationBarBackButtonHidden(true)
            .toolbar { 
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { viewStore.send(.backButtonTapped) } label: { 
                        Image("ic_chevron_left_ios_24")
                    }
                    .frame(width: 48, height: 48)
                }
            }
    }
    
    var bodyView: some View {
        VStack(spacing: .zero) { 
            Text("만든 사람들")
                .font(pretendard: .display1)
                .foregroundStyle(Color.grey80)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
            
            HStack(spacing: .zero) { 
                Image("hajin")
                    .resizable()
                    .frame(width: 72, height: 72)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                
                VStack(spacing: .zero) { 
                    Text("UI/UX Designer")
                        .font(pretendard: .body4)
                        .foregroundColor(.grey40)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Hajin Lee")
                        .font(pretendard: .heading3)
                        .foregroundColor(.text_secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
            }
            .background(Color.elevated)
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            
            HStack(spacing: .zero) { 
                Image("havi")
                    .resizable()
                    .frame(width: 72, height: 72)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                
                VStack(spacing: .zero) { 
                    Text("iOS Developer")
                        .font(pretendard: .body4)
                        .foregroundColor(.grey40)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("havi.log")
                        .font(pretendard: .heading3)
                        .foregroundColor(.text_secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
            }
            .background(Color.elevated)
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            
            HStack(spacing: .zero) { 
                Image("juah")
                    .resizable()
                    .frame(width: 72, height: 72)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                
                VStack(spacing: .zero) { 
                    Text("Android Developer")
                        .font(pretendard: .body4)
                        .foregroundColor(.grey40)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("juah.n")
                        .font(pretendard: .heading3)
                        .foregroundColor(.text_secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
            }
            .background(Color.elevated)
            .cornerRadius(12)
            .padding(.horizontal, 20)
            
            Spacer()
            
            Image("ic_instagram_24")
                .padding(.all, 10)
                .background(Color.grey10)
                .cornerRadius(radius: 22, corners: .allCorners)
                .padding(.bottom, 8)
            
            Text("@dayroom_official")
                .font(pretendard: .body2)
                .foregroundColor(.text_secondary)
                .padding(.bottom, 14)
        }
    }
}

struct WhoMadeThisView_Previews: PreviewProvider {
    static var previews: some View {
        WhoMadeThisView(
            store: .init(
                initialState: .init(), 
                reducer: WhoMadeThis()
            )
        )
    }
}

