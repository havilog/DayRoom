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
    
    var save: @Sendable (UUID?, Data?, Date, String?, String?) throws -> Void
    var edit: @Sendable (Diary, Data?, Date, String?, String?) throws -> Void
    var load: @Sendable () throws -> [Diary]
    var remove: @Sendable (Diary) -> Void
}

extension PersistenceManager: DependencyKey {
    static var liveValue: PersistenceManager = .init(
        save: { id, imageData, date, content, mood in
            let newDiary: Diary = .init(context: Self.container.viewContext)
            newDiary.id = id
            newDiary.image = imageData
            newDiary.date = date
            newDiary.content = content
            newDiary.mood = mood
            try container.viewContext.save()
        },
        edit: { diary, imageData, date, content, mood in
            diary.image = imageData
            diary.date = date
            diary.content = content
            diary.mood = mood
            try container.viewContext.save()
        },
        load: {
            let context = container.newBackgroundContext()
            let fetchRequest: NSFetchRequest<Diary> = Diary.fetchRequest()
            let sortByDate: NSSortDescriptor = .init(key: #keyPath(Diary.date), ascending: false)
            fetchRequest.sortDescriptors = [sortByDate]
            let diaries = try container.viewContext.fetch(fetchRequest)
            return diaries
        },
        remove: { diary in
            container.viewContext.delete(diary)
            try? container.viewContext.save()
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
