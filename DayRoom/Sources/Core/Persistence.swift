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
        static let diaryContainerName: String = "DayRoom"
    }
    
    private static var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constant.diaryContainerName)
        container.loadPersistentStores { storeDescription, error in
            if let error { fatalError() }
        }
        return container
    }()
    
    var save: @Sendable (Data?, Date, String) throws -> Void
    var load: @Sendable () throws -> [Diary]
}

extension PersistenceManager: DependencyKey {
    static var liveValue: PersistenceManager = .init(
        save: { imageData, date, content in
            let newDiary: Diary = .init(context: Self.container.viewContext)
            newDiary.id = .init()
            newDiary.image = imageData
            newDiary.date = date
            newDiary.content = content
            try Self.container.viewContext.save()
        },
        load: {
            let context = container.newBackgroundContext()
            let fetchRequest: NSFetchRequest<Diary> = Diary.fetchRequest()
            let sortByDate: NSSortDescriptor = .init(key: #keyPath(Diary.date), ascending: false)
            fetchRequest.sortDescriptors = [sortByDate]
            let results = try container.viewContext.fetch(fetchRequest)
            return results
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
