//
//  TextRepository.swift
//  StudySprint
//

import Foundation
import Combine

class TextRepository: TextRepositoryProtocol {
    private let dataSource: LocalDataSource
    
    init(dataSource: LocalDataSource) {
        self.dataSource = dataSource
    }
    
    func getText(for sessionId: UUID) -> AnyPublisher<StudyTextEntity?, Error> {
        return dataSource.fetchCategories()
            .flatMap { categories -> AnyPublisher<StudyTextEntity?, Error> in
                for category in categories {
                    if let sessions = category.sessions?.allObjects as? [SessionMO],
                       let session = sessions.first(where: { $0.id == sessionId }),
                       let text = session.studyText {
                        let entity = StudyTextEntity(
                            id: text.id ?? UUID(),
                            content: text.content ?? "",
                            wpm: Int(text.wpm),
                            fontSize: Int(text.fontSize),
                            musicTrack: text.musicTrack,
                            rating: text.rating,
                            lastReadAt: text.lastReadAt,
                            progressIndex: Int(text.progressIndex),
                            sessionId: sessionId,
                            isMetronomeEnabled: text.isMetronomeEnabled
                        )
                        return Just(entity).setFailureType(to: Error.self).eraseToAnyPublisher()
                    }
                }
                return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func saveText(_ text: StudyTextEntity) -> AnyPublisher<StudyTextEntity, Error> {
        return dataSource.fetchCategories()
            .flatMap { categories -> AnyPublisher<StudyTextEntity, Error> in
                for category in categories {
                    if let sessions = category.sessions?.allObjects as? [SessionMO],
                       let session = sessions.first(where: { $0.id == text.sessionId }) {
                        _ = self.dataSource.createText(content: text.content, wpm: Int32(text.wpm), fontSize: Int32(text.fontSize), session: session)
                        return self.dataSource.saveContext()
                            .map { text }
                            .eraseToAnyPublisher()
                    }
                }
                return Fail(error: NSError(domain: "", code: 404)).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func updateText(_ text: StudyTextEntity) -> AnyPublisher<StudyTextEntity, Error> {
        return dataSource.fetchCategories()
            .flatMap { categories -> AnyPublisher<StudyTextEntity, Error> in
                for category in categories {
                    if let sessions = category.sessions?.allObjects as? [SessionMO],
                       let session = sessions.first(where: { $0.id == text.sessionId }),
                       let existing = session.studyText {
                        existing.content = text.content
                        existing.wpm = Int32(text.wpm)
                        existing.fontSize = Int32(text.fontSize)
                        existing.rating = text.rating
                        existing.lastReadAt = text.lastReadAt
                        existing.progressIndex = Int32(text.progressIndex)
                        existing.isMetronomeEnabled = text.isMetronomeEnabled
                        return self.dataSource.saveContext()
                            .map { text }
                            .eraseToAnyPublisher()
                    }
                }
                return Fail(error: NSError(domain: "", code: 404)).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func deleteText(id: UUID) -> AnyPublisher<Void, Error> {
        return dataSource.fetchCategories()
            .flatMap { categories -> AnyPublisher<Void, Error> in
                for category in categories {
                    if let sessions = category.sessions?.allObjects as? [SessionMO] {
                        for session in sessions {
                            if let text = session.studyText, text.id == id {
                                return self.dataSource.deleteObject(text)
                            }
                        }
                    }
                }
                return Fail(error: NSError(domain: "", code: 404)).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getAllTexts() -> AnyPublisher<[StudyTextEntity], Error> {
        return dataSource.fetchCategories()
            .flatMap { categories -> AnyPublisher<[StudyTextEntity], Error> in
                var texts: [StudyTextEntity] = []
                for category in categories {
                    if let sessions = category.sessions?.allObjects as? [SessionMO] {
                        for session in sessions {
                            if let text = session.studyText {
                                let entity = StudyTextEntity(
                                    id: text.id ?? UUID(),
                                    content: text.content ?? "",
                                    wpm: Int(text.wpm),
                                    fontSize: Int(text.fontSize),
                                    musicTrack: text.musicTrack,
                                    rating: text.rating,
                                    lastReadAt: text.lastReadAt,
                                    progressIndex: Int(text.progressIndex),
                                    sessionId: session.id ?? UUID(),
                                    isMetronomeEnabled: text.isMetronomeEnabled
                                )
                                texts.append(entity)
                            }
                        }
                    }
                }
                return Just(texts).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
