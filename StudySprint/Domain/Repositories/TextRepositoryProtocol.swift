//
//  TextRepositoryProtocol.swift
//  StudySprint
//

import Foundation
import Combine

protocol TextRepositoryProtocol {
    func getText(for sessionId: UUID) -> AnyPublisher<StudyTextEntity?, Error>
    func saveText(_ text: StudyTextEntity) -> AnyPublisher<StudyTextEntity, Error>
    func updateText(_ text: StudyTextEntity) -> AnyPublisher<StudyTextEntity, Error>
    func deleteText(sessionId: UUID) -> AnyPublisher<Void, Error>
    func getAllTexts() -> AnyPublisher<[StudyTextEntity], Error>
}
