//
//  CategoryRepository.swift
//  StudySprint
//

import Foundation
import Combine
internal import CoreData

class CategoryRepository: CategoryRepositoryProtocol {
    private let dataSource: LocalDataSource
    
    init(dataSource: LocalDataSource) {
        self.dataSource = dataSource
    }
    
    func getCategories() -> AnyPublisher<[CategoryEntity], Error> {
        return dataSource.fetchCategories()
            .map { categories in
                categories.map { category in
                    CategoryEntity(
                        id: category.id ?? UUID(),
                        name: category.name ?? "",
                        description: category.categoryDescription,
                        createdAt: category.createdAt ?? Date()
                    )
                }
            }
            .eraseToAnyPublisher()
    }
    
    func createCategory(name: String, description: String?) -> AnyPublisher<CategoryEntity, Error> {
        return Future { promise in
            _ = self.dataSource.createCategory(name: name, description: description)
            self.dataSource.saveContext()
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            promise(.failure(error))
                        }
                    },
                    receiveValue: {
                        promise(.success(CategoryEntity(name: name, description: description)))
                    }
                )
                .store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
    
    func updateCategory(_ category: CategoryEntity) -> AnyPublisher<CategoryEntity, Error> {
        return dataSource.fetchCategories()
            .flatMap { categories -> AnyPublisher<CategoryEntity, Error> in
                guard let existing = categories.first(where: { $0.id == category.id }) else {
                    return Fail(error: NSError(domain: "", code: 404)).eraseToAnyPublisher()
                }
                existing.name = category.name
                existing.categoryDescription = category.description
                return self.dataSource.saveContext()
                    .map { category }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func deleteCategory(id: UUID) -> AnyPublisher<Void, Error> {
        return dataSource.fetchCategories()
            .flatMap { categories -> AnyPublisher<Void, Error> in
                guard let existing = categories.first(where: { $0.id == id }) else {
                    return Fail(error: NSError(domain: "", code: 404)).eraseToAnyPublisher()
                }
                return self.dataSource.deleteObject(existing)
            }
            .eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()
}
