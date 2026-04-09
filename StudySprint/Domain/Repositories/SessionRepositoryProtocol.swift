//
//  SessionRepositoryProtocol.swift
//  StudySprint
//

import Foundation
import Combine

protocol SessionRepositoryProtocol {
    func getSessions(for categoryId: UUID) -> AnyPublisher<[SessionEntity], Error>
    func createSession(name: String, description: String?, categoryId: UUID) -> AnyPublisher<SessionEntity, Error>
    func updateSession(_ session: SessionEntity) -> AnyPublisher<SessionEntity, Error>
    func deleteSession(id: UUID) -> AnyPublisher<Void, Error>
}
