//
//  DayRoomApp.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/08.
//

import SwiftUI
import ComposableArchitecture

@main
struct DayRoomApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(
                store: .init(
                    initialState: .init(), 
                    reducer: RootFeature()
                )
            )
        }
    }
}
