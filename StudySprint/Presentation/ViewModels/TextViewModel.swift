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
            }
            .store(in: &cancellables)
    }
    
    func saveSettings() {
        guard var text = studyText else { return }
        text.wpm = wpm
        text.fontSize = fontSize
        updateText(text)
    }
    
    func deleteText() {
        guard let text = studyText else { return }
        useCases.deleteText(id: text.id)
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
}
