//
//  SessionEntity.swift
//  StudySprint
//

import Foundation

struct SessionEntity: Identifiable, Equatable {
    let id: UUID
    var name: String
    var description: String?
    let createdAt: Date
    let categoryId: UUID
    
    init(id: UUID = UUID(), name: String, description: String? = nil,
         createdAt: Date = Date(), orderIndex: Int = 0, categoryId: UUID) {
        self.id = id
        self.name = name
        self.description = description
        self.createdAt = createdAt
        self.categoryId = categoryId
    }
}
