//
//  Persistence.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/08.
//

import CoreData
import XCTestDynamicOverlay
import ComposableArchitecture

class PersistenceManager {
    private enum Constant {
        static let diaryContainerName: String = "DayRoomDiary"
    }
    
    static let shared: PersistenceManager = .init()
    
    private init() { }
    
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constant.diaryContainerName)
        container.loadPersistentStores { storeDescription, error in
            if let error { fatalError() }
        }
        return container
    }()
    
    init(inMemory: Bool = false) {
        if inMemory { self.container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null") }
        self.container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension PersistenceManager: DependencyKey {
    static var liveValue: PersistenceManager = .shared
    static var testValue: PersistenceManager = unimplemented()
}

extension DependencyValues {
    var persistence: PersistenceManager {
        get { self[PersistenceManager.self] }
        set { self[PersistenceManager.self] = newValue }
    }
}
