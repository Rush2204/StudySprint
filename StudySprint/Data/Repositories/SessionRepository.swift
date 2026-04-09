//
//  SessionRepository.swift
//  StudySprint
//

import Foundation
import Combine

class SessionRepository: SessionRepositoryProtocol {
    private let dataSource: LocalDataSource
    
    init(dataSource: LocalDataSource) {
        self.dataSource = dataSource
    }
    
    func getSessions(for categoryId: UUID) -> AnyPublisher<[SessionEntity], Error> {
        return dataSource.fetchCategories()
            .flatMap { categories -> AnyPublisher<[SessionEntity], Error> in
                guard let category = categories.first(where: { $0.id == categoryId }) else {
                    return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                
                guard let sessionsSet = category.sessions as? Set<SessionMO> else {
                    return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                
                let sessions = Array(sessionsSet)
                
                let sortedSessions = sessions.sorted {
                    guard let date1 = $0.createdAt, let date2 = $1.createdAt else {
                        return false
                    }
                    return date1 > date2  // Más reciente primero
                }
                
                let entities = sortedSessions.map { session in
                    SessionEntity(
                        id: session.id ?? UUID(),
                        name: session.name ?? "",
                        description: session.sessionDescription,
                        createdAt: session.createdAt ?? Date(),
                        categoryId: categoryId
                    )
                }
                
                return Just(entities).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func createSession(name: String, description: String?, categoryId: UUID) -> AnyPublisher<SessionEntity, Error> {
        return dataSource.fetchCategories()
            .flatMap { categories -> AnyPublisher<SessionEntity, Error> in
                guard let category = categories.first(where: { $0.id == categoryId }) else {
                    return Fail(error: NSError(domain: "", code: 404)).eraseToAnyPublisher()
                }
                _ = self.dataSource.createSession(name: name, description: description, category: category)
                return self.dataSource.saveContext()
                    .map {
                        SessionEntity(name: name, description: description, categoryId: categoryId)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func updateSession(_ session: SessionEntity) -> AnyPublisher<SessionEntity, Error> {
        return dataSource.fetchCategories()
            .flatMap { categories -> AnyPublisher<SessionEntity, Error> in
                guard let category = categories.first(where: { $0.id == session.categoryId }),
                      let existing = (category.sessions?.allObjects as? [SessionMO])?.first(where: { $0.id == session.id }) else {
                    return Fail(error: NSError(domain: "", code: 404)).eraseToAnyPublisher()
                }
                existing.name = session.name
                existing.sessionDescription = session.description
                return self.dataSource.saveContext()
                    .map { session }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func deleteSession(id: UUID) -> AnyPublisher<Void, Error> {
        return dataSource.fetchCategories()
            .flatMap { categories -> AnyPublisher<Void, Error> in
                var sessionToDelete: SessionMO?
                for category in categories {
                    if let session = (category.sessions?.allObjects as? [SessionMO])?.first(where: { $0.id == id }) {
                        sessionToDelete = session
                        break
                    }
                }
                guard let session = sessionToDelete else {
                    return Fail(error: NSError(domain: "", code: 404)).eraseToAnyPublisher()
                }
                return self.dataSource.deleteObject(session)
            }
            .eraseToAnyPublisher()
    }
}
