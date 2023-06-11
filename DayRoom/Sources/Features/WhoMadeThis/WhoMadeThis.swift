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
        case delegate(Delegate)
        enum Delegate {
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
            
        case .delegate:
            return .none
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
            .padding(.top, 24)
            .navigationBarBackButtonHidden(true)
            .toolbar { 
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { viewStore.send(.backButtonTapped) } label: { 
                        Image("ic_chevron_left_ios_24")
                    }
                    .frame(width: 48, height: 48)
                }
                ToolbarItem(placement: .principal) {
                    Text("만든사람들")
                        .font(pretendard: .heading3)
                        .foregroundColor(.text_primary)
                }
            }
    }
    
    var bodyView: some View {
        VStack(spacing: .zero) { 
            HStack(spacing: .zero) { 
                Image("logo_dayroom_symbol")
                    .resizable()
                    .frame(width: 66, height: 66)
                    .padding(.horizontal, 21)
                    .padding(.top, 18)
                    .padding(.bottom, 24)
                
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
            .cornerRadius(24)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            
            HStack(spacing: .zero) { 
                Image("logo_dayroom_symbol")
                    .resizable()
                    .frame(width: 66, height: 66)
                    .padding(.horizontal, 21)
                    .padding(.top, 18)
                    .padding(.bottom, 24)
                
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
            .cornerRadius(24)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            
            HStack(spacing: .zero) { 
                Image("logo_dayroom_symbol")
                    .resizable()
                    .frame(width: 66, height: 66)
                    .padding(.horizontal, 21)
                    .padding(.top, 18)
                    .padding(.bottom, 24)
                
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
            .cornerRadius(24)
            .padding(.horizontal, 20)
            
            Spacer()
            
            Image("logo_dayroom_symbol")
                .padding(.bottom, 24)
            HStack(spacing: .zero) { 
                Image("ic_instagram_24")
                Text("dayroom_official")
                    .font(pretendard: .body2)
                    .foregroundColor(.text_secondary)
            }
            Text("team.dayroom@gmail.com")
                .font(pretendard: .body2)
                .foregroundColor(.text_secondary)
                .padding(.bottom, 48)
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

