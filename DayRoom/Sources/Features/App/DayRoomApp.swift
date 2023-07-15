//
//  DayRoomApp.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/08.
//

import SwiftUI
import FirebaseCore
import ComposableArchitecture

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct DayRoomApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            RootView(
                store: .init(
                    initialState: .init(), 
                    reducer: Root()
                )
            )
        }
    }
}
