//
//  CategoryDTO.swift
//  StudySprint
//

import Foundation

struct CategoryDTO {
    let id: UUID
    let name: String
    let categoryDescription: String?
    let createdAt: Date
    
    func toEntity() -> CategoryEntity {
        return CategoryEntity(
            id: id,
            name: name,
            description: categoryDescription,
            createdAt: createdAt
        )
    }
    
    static func fromEntity(_ entity: CategoryEntity) -> CategoryDTO {
        return CategoryDTO(
            id: entity.id,
            name: entity.name,
            categoryDescription: entity.description,
            createdAt: entity.createdAt
        )
    }
}
