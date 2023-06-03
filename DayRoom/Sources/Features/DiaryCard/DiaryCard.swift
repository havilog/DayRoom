//
//  DiaryCard.swift
//  DayRoom
//
//  Created by 한상진 on 2023/06/01.
//

import SwiftUI

import ComposableArchitecture

struct DiaryCard: Reducer {
    
    enum CardPage: Equatable {
        case photo
        case content
    }
    
    // MARK: State
    
    struct State: Equatable {
        var date: Date = .today
        var mood: DiaryMood
        var selectedImage: UIImage? = nil
        var content: String = ""
        var page: CardPage = .photo
    }
    
    // MARK: Action
    
    enum Action: Equatable {
        case viewTapped
        case flipCard
        case delegate(Delegate)
        enum Delegate: Equatable {
            case needPhotoPicker
        }
    }
    
    // MARK: Dependency
    
    // MARK: Body
    
    var body: some ReducerOf<Self> {
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .viewTapped:
            if state.selectedImage == nil {
                return .send(.delegate(.needPhotoPicker))
            }
            return flip(&state)
            
        case .flipCard:
            return flip(&state)
            
        case .delegate:
            return .none
        }
    }
    
    private func flip(_ state: inout State) -> Effect<Action> {
        if state.page == .photo {
            state.page = .content
        } else {
            state.page = .photo
        }
        
        return .none
    }
}

struct DiaryCardView: View {
    let store: StoreOf<DiaryCard>
    @ObservedObject var viewStore: ViewStoreOf<DiaryCard>
    
    init(store: StoreOf<DiaryCard>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        bodyView
    }
    
    private var bodyView: some View {
        ZStack {
            photoView
                .opacity(viewStore.page == .photo ? 1 : 0)
                .rotation3DEffect(
                    .degrees(viewStore.page == .photo ? 0 : 180), 
                    axis: (x: .zero, y: -1, z: .zero),
                    perspective: 0.3
                )
            contentView
                .opacity(viewStore.page == .photo ? 0 : 1)
                .rotation3DEffect(
                    .degrees(viewStore.page == .photo ? -180 : 0), 
                    axis: (x: .zero, y: -1, z: .zero),
                    perspective: 0.3
                )
        }
        .animation(.easeInOut(duration: 0.75), value: viewStore.page)
        .onTapGesture { viewStore.send(.viewTapped) }
        .debug(.day_brown)
    }
    
    private var photoView: some View {
        ZStack(alignment: .bottom) {
            photoContent(viewStore.selectedImage)
                .frame(height: 500)
                .frame(maxWidth: .infinity)
                .cornerRadius(24)
                .contentShape(Rectangle())
            
            VStack(spacing: .zero) { 
                Text(String(viewStore.date.day))
                    .font(garamond: .hero)
                    .foregroundColor(viewStore.selectedImage == nil ? .text_disabled : .day_white)
                
                Text(viewStore.date.weekday.english)
                    .font(garamond: .body2)
                    .foregroundColor(viewStore.selectedImage == nil ? .text_disabled : .day_white)
            }
            .padding(24)
        }
    }
    
    @ViewBuilder
    private func photoContent(_ image: UIImage?) -> some View {
        if let image {
            Image(uiImage: image).resizable()
        } else {
            Color.elevated
        }
    }

    private var contentView: some View {
        Color.day_brown
            .frame(height: 500)
            .frame(maxWidth: .infinity)
            .cornerRadius(24)
            .contentShape(Rectangle())
    }
}

struct DiaryCardView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryCardView(
            store: .init(
                initialState: .init(date: .today, mood: .lucky), 
                reducer: DiaryCard()
            )
        )
    }
}

//extension AnyTransition {
//    static var rotate: AnyTransition { get {
//        AnyTransition.modifier(active: RotateTransition(percent: 0), identity: RotateTransition(percent: 1))
//        }
//    }
//}
//
//struct RotateTransition: GeometryEffect {
//    var percent: Double
//    
//    var animatableData: Double {
//        get { percent }
//        set { percent = newValue }
//    }
//    
//    func effectValue(size: CGSize) -> ProjectionTransform {
//
//        let rotationPercent = percent
//        let a = CGFloat(Angle(degrees: 170 * (1-rotationPercent)).radians)
//        
//        var transform3d = CATransform3DIdentity;
//        transform3d.m34 = -1/max(size.width, size.height)
//        
//        transform3d = CATransform3DRotate(transform3d, a, 0, 1, 0)
//        transform3d = CATransform3DTranslate(transform3d, -size.width/2.0, -size.height/2.0, 0)
//        
//        let affineTransform1 = ProjectionTransform(CGAffineTransform(translationX: size.width/2.0, y: size.height / 2.0))
//        let affineTransform2 = ProjectionTransform(CGAffineTransform(scaleX: CGFloat(percent * 2), y: CGFloat(percent * 2)))
//        
//        if percent <= 0.5 {
//            return ProjectionTransform(transform3d).concatenating(affineTransform2).concatenating(affineTransform1)
//        } else {
//            return ProjectionTransform(transform3d).concatenating(affineTransform1)
//        }
//    }
//}
