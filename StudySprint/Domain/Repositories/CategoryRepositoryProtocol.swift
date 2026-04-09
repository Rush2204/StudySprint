//
//  CategoryRepositoryProtocol.swift
//  StudySprint
//

import Foundation
import Combine

protocol CategoryRepositoryProtocol {
    func getCategories() -> AnyPublisher<[CategoryEntity], Error>
    func createCategory(name: String, description: String?) -> AnyPublisher<CategoryEntity, Error>
    func updateCategory(_ category: CategoryEntity) -> AnyPublisher<CategoryEntity, Error>
    func deleteCategory(id: UUID) -> AnyPublisher<Void, Error>
}
