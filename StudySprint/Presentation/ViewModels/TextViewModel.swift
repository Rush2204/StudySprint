//
//  TextViewModel.swift
//  StudySprint
//

import Foundation
import SwiftUI
import Combine

@MainActor
class TextViewModel: ObservableObject {
    @Published var studyText: StudyTextEntity?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var wpm: Int = AppConstants.defaultWPM
    @Published var fontSize: Int = AppConstants.defaultFontSize
    @Published var isMetronomeEnabled: Bool = false
    @Published var showDeleteConfirmation: Bool = false
    
    
    private let useCases: TextUseCasesProtocol
    private let sessionId: UUID
    private var cancellables = Set<AnyCancellable>()
    
    init(useCases: TextUseCasesProtocol, sessionId: UUID) {
        self.useCases = useCases
        self.sessionId = sessionId
        loadText()
    }
    
    func loadText() {
        isLoading = true
        useCases.getText(for: sessionId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] text in
                self?.studyText = text
                if let text = text {
                    self?.wpm = text.wpm
                    self?.fontSize = text.fontSize
                    self?.isMetronomeEnabled = text.isMetronomeEnabled
                }
            }
            .store(in: &cancellables)
    }
    
    func saveManualText(_ content: String) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        if let existing = studyText {
            var updated = existing
            updated.content = trimmed
            updated.wpm = wpm
            updated.fontSize = fontSize
            updateText(updated)
        } else {
            useCases.saveText(content: trimmed, sessionId: sessionId, wpm: wpm, fontSize: fontSize)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                } receiveValue: { [weak self] text in
                    self?.studyText = text
                }
                .store(in: &cancellables)
        }
    }
    
    func updateManualText(_ newContent: String) {
        let trimmed = newContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        guard var text = studyText else { return }
        text.content = trimmed
        updateText(text)
    }
    
    func savePDFText(_ content: String) {
        saveManualText(content)
    }
    
    func updateText(_ text: StudyTextEntity) {
        useCases.updateText(text)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] updatedText in
                self?.studyText = updatedText
                self?.isMetronomeEnabled = updatedText.isMetronomeEnabled
            }
            .store(in: &cancellables)
    }
    
    
    func saveSettings() {
        guard var text = studyText else { return }
        text.wpm = wpm
        text.fontSize = fontSize
        updateText(text)
    }
    
    func confirmDeletion() {
        guard studyText != nil else { return }
        self.showDeleteConfirmation = true
    }
    
    func deleteText() {
        useCases.deleteText(id: sessionId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.studyText = nil
            }
            .store(in: &cancellables)
    }
    
    func toggleMetronome(_ enabled: Bool) {
        saveMetronomeStateDirectly(enabled)
    }
    
    
    func saveMetronomeStateDirectly(_ enabled: Bool) {
        isMetronomeEnabled = enabled
        
        guard let text = studyText else {
            return
        }
        
        // Crear entidad actualizada
        var updatedText = text
        updatedText.isMetronomeEnabled = enabled
        
        // Usar el caso de uso para guardar
        useCases.updateText(updatedText)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] savedText in
                self?.studyText = savedText
                self?.isMetronomeEnabled = savedText.isMetronomeEnabled
            }
            .store(in: &cancellables)
    }
}
