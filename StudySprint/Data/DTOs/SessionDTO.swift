//
//  SessionDTO.swift
//  StudySprint
//

import Foundation

struct SessionDTO {
    let id: UUID
    let name: String
    let sessionDescription: String?
    let createdAt: Date
    let categoryId: UUID
    
    func toEntity() -> SessionEntity {
        return SessionEntity(
            id: id,
            name: name,
            description: sessionDescription,
            createdAt: createdAt,
            categoryId: categoryId
        )
    }
    
    static func fromEntity(_ entity: SessionEntity, categoryId: UUID) -> SessionDTO {
        return SessionDTO(
            id: entity.id,
            name: entity.name,
            sessionDescription: entity.description,
            createdAt: entity.createdAt,
            categoryId: categoryId
        )
    }
}
