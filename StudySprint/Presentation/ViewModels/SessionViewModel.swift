//
//  SessionViewModel.swift
//  StudySprint
//

import Foundation
import SwiftUI
import Combine

@MainActor
class SessionViewModel: ObservableObject {
    @Published var sessions: [SessionEntity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let useCases: SessionUseCasesProtocol
    private let categoryId: UUID
    private var cancellables = Set<AnyCancellable>()
    
    init(useCases: SessionUseCasesProtocol, categoryId: UUID) {
        self.useCases = useCases
        self.categoryId = categoryId
        loadSessions()
    }
    
    func loadSessions() {
        isLoading = true
        useCases.getSessions(for: categoryId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] sessions in
                self?.sessions = sessions
            }
            .store(in: &cancellables)
    }
    
    func createSession(name: String, description: String?) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        if let desc = description, desc.count > 200 {
                self.errorMessage = "La descripción no puede exceder los 200 caracteres"
                return
            }
        
        useCases.createSession(name: name, description: description, categoryId: categoryId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.loadSessions()
            }
            .store(in: &cancellables)
    }
    
    func updateSession(_ session: SessionEntity, name: String, description: String?) {
        if let desc = description, desc.count > 200 {
                self.errorMessage = "La descripción es demasiado larga (máx. 200)"
                return
            }
        var updated = session
        updated.name = name
        updated.description = description
        
        useCases.updateSession(updated)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.loadSessions()
            }
            .store(in: &cancellables)
    }
    
    func deleteSession(_ session: SessionEntity) {
        useCases.deleteSession(id: session.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.loadSessions()
            }
            .store(in: &cancellables)
    }
}
