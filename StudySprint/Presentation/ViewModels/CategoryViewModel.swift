//
//  CategoryViewModel.swift
//  StudySprint
//

import Foundation
import SwiftUI
import Combine

@MainActor
class CategoryViewModel: ObservableObject {
    @Published var categories: [CategoryEntity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let useCases: CategoryUseCasesProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(useCases: CategoryUseCasesProtocol) {
        self.useCases = useCases
        loadCategories()
    }
    
    func loadCategories() {
        isLoading = true
        useCases.getCategories()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] categories in
                self?.categories = categories
            }
            .store(in: &cancellables)
    }
    
    func createCategory(name: String, description: String?) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        useCases.createCategory(name: name, description: description)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.loadCategories()
            }
            .store(in: &cancellables)
    }
    
    func updateCategory(_ category: CategoryEntity, name: String, description: String?) {
        var updated = category
        updated.name = name
        updated.description = description
        
        useCases.updateCategory(updated)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.loadCategories()
            }
            .store(in: &cancellables)
    }
    
    func deleteCategory(_ category: CategoryEntity) {
        useCases.deleteCategory(id: category.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.loadCategories()
            }
            .store(in: &cancellables)
    }
}
