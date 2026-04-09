//
//  SessionUseCases.swift
//  StudySprint
//

import Foundation
import Combine

protocol SessionUseCasesProtocol {
    func getSessions(for categoryId: UUID) -> AnyPublisher<[SessionEntity], Error>
    func createSession(name: String, description: String?, categoryId: UUID) -> AnyPublisher<SessionEntity, Error>
    func updateSession(_ session: SessionEntity) -> AnyPublisher<SessionEntity, Error>
    func deleteSession(id: UUID) -> AnyPublisher<Void, Error>
}

class SessionUseCases: SessionUseCasesProtocol {
    private let repository: SessionRepositoryProtocol
    
    init(repository: SessionRepositoryProtocol) {
        self.repository = repository
    }
    
    func getSessions(for categoryId: UUID) -> AnyPublisher<[SessionEntity], Error> {
        return repository.getSessions(for: categoryId)
    }
    
    func createSession(name: String, description: String?, categoryId: UUID) -> AnyPublisher<SessionEntity, Error> {
        return repository.createSession(name: name, description: description, categoryId: categoryId)
    }
    
    func updateSession(_ session: SessionEntity) -> AnyPublisher<SessionEntity, Error> {
        return repository.updateSession(session)
    }
    
    func deleteSession(id: UUID) -> AnyPublisher<Void, Error> {
        return repository.deleteSession(id: id)
    }
}
