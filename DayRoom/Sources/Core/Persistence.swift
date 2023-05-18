//
//  Persistence.swift
//  DayRoom
//
//  Created by 한상진 on 2023/05/08.
//

import CoreData
import Foundation
import XCTestDynamicOverlay
import ComposableArchitecture

struct PersistenceManager {
    private enum Constant {
        static let diaryContainerName: String = "DayRoomDiary"
    }
    
    private static var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constant.diaryContainerName)
        container.loadPersistentStores { storeDescription, error in
            if let error { fatalError() }
        }
        return container
    }()
    
    var save: @Sendable (Data, Date, String) throws -> Void
}

extension PersistenceManager: DependencyKey {
    static var liveValue: PersistenceManager = .init(
        save: { imageData, date, content in
            let newDiary: Diary = .init(context: Self.container.viewContext)
            // TODO: id, image, identifiable
            newDiary.setValue(imageData, forKey: #keyPath(Diary.image))
            newDiary.setValue(date, forKey: #keyPath(Diary.date))
            newDiary.setValue(content, forKey: #keyPath(Diary.content))
            try Self.container.viewContext.save()
        }
    )
    static var testValue: PersistenceManager = unimplemented()
}

extension DependencyValues {
    var persistence: PersistenceManager {
        get { self[PersistenceManager.self] }
        set { self[PersistenceManager.self] = newValue }
    }
}
