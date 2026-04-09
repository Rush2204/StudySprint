//
//  CategoryUseCases.swift
//  StudySprint
//

import Foundation
import Combine

protocol CategoryUseCasesProtocol {
    func getCategories() -> AnyPublisher<[CategoryEntity], Error>
    func createCategory(name: String, description: String?) -> AnyPublisher<CategoryEntity, Error>
    func updateCategory(_ category: CategoryEntity) -> AnyPublisher<CategoryEntity, Error>
    func deleteCategory(id: UUID) -> AnyPublisher<Void, Error>
}

class CategoryUseCases: CategoryUseCasesProtocol {
    private let repository: CategoryRepositoryProtocol
    
    init(repository: CategoryRepositoryProtocol) {
        self.repository = repository
    }
    
    func getCategories() -> AnyPublisher<[CategoryEntity], Error> {
        return repository.getCategories()
    }
    
    func createCategory(name: String, description: String?) -> AnyPublisher<CategoryEntity, Error> {
        return repository.createCategory(name: name, description: description)
    }
    
    func updateCategory(_ category: CategoryEntity) -> AnyPublisher<CategoryEntity, Error> {
        return repository.updateCategory(category)
    }
    
    func deleteCategory(id: UUID) -> AnyPublisher<Void, Error> {
        return repository.deleteCategory(id: id)
    }
}
