//
//  TextUseCases.swift
//  StudySprint
//

import Foundation
import Combine

protocol TextUseCasesProtocol {
    func getText(for sessionId: UUID) -> AnyPublisher<StudyTextEntity?, Error>
    func saveText(content: String, sessionId: UUID, wpm: Int, fontSize: Int) -> AnyPublisher<StudyTextEntity, Error>
    func updateText(_ text: StudyTextEntity) -> AnyPublisher<StudyTextEntity, Error>
    func deleteText(id: UUID) -> AnyPublisher<Void, Error>
    func getAllTexts() -> AnyPublisher<[StudyTextEntity], Error>
}

class TextUseCases: TextUseCasesProtocol {
    private let repository: TextRepositoryProtocol
    
    init(repository: TextRepositoryProtocol) {
        self.repository = repository
    }
    
    func getText(for sessionId: UUID) -> AnyPublisher<StudyTextEntity?, Error> {
        return repository.getText(for: sessionId)
    }
    
    func saveText(content: String, sessionId: UUID, wpm: Int, fontSize: Int) -> AnyPublisher<StudyTextEntity, Error> {
        let text = StudyTextEntity(
            content: content,
            wpm: wpm,
            fontSize: fontSize,
            sessionId: sessionId
        )
        return repository.saveText(text)
    }
    
    func updateText(_ text: StudyTextEntity) -> AnyPublisher<StudyTextEntity, Error> {
        return repository.updateText(text)
    }
    
    func deleteText(id: UUID) -> AnyPublisher<Void, Error> {
        return repository.deleteText(id: id)
    }
    
    func getAllTexts() -> AnyPublisher<[StudyTextEntity], Error> {
        return repository.getAllTexts()
    }
}
