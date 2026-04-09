//
//  LocalDataSource.swift
//  StudySprint
//


import Foundation
import Combine
internal import CoreData

final class LocalDataSource {
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    // MARK: - Fetch Categories
    func fetchCategories() -> AnyPublisher<[CategoryMO], Error> {
        let request: NSFetchRequest<CategoryMO> = CategoryMO.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CategoryMO.name, ascending: true)]
        
        do {
            let categories = try viewContext.fetch(request)
            return Just(categories)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    // MARK: - Save Context
    func saveContext() -> AnyPublisher<Void, Error> {
        return Future { promise in
            if self.viewContext.hasChanges {
                do {
                    try self.viewContext.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            } else {
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - Delete Object
    func deleteObject(_ object: NSManagedObject) -> AnyPublisher<Void, Error> {
        return Future { promise in
            self.viewContext.delete(object)
            do {
                try self.viewContext.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - Create Category
    func createCategory(name: String, description: String?) -> CategoryMO {
        let category = CategoryMO(context: viewContext)
        category.id = UUID()
        category.name = name
        category.categoryDescription = description
        category.createdAt = Date()
        return category
    }
    
    // MARK: - Create Session
    func createSession(name: String, description: String?, category: CategoryMO) -> SessionMO {
        let session = SessionMO(context: viewContext)
        session.id = UUID()
        session.name = name
        session.sessionDescription = description
        session.createdAt = Date()
        session.category = category
        return session
    }
    
    // MARK: - Create Text
    func createText(content: String, wpm: Int32, fontSize: Int32, session: SessionMO) -> StudyTextMO {
        let text = StudyTextMO(context: viewContext)
        text.id = UUID()
        text.content = content
        text.wpm = wpm
        text.fontSize = fontSize
        text.rating = 0
        text.progressIndex = 0
        text.session = session
        return text
    }
}
