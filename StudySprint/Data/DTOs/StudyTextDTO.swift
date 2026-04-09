//
//  StudyTextDTO.swift
//  StudySprint
//

import Foundation

struct StudyTextDTO {
    let id: UUID
    let content: String
    let wpm: Int32
    let fontSize: Int32
    let musicTrack: String?
    let rating: Double
    let lastReadAt: Date?
    let progressIndex: Int32
    let sessionId: UUID
    
    func toEntity() -> StudyTextEntity {
        return StudyTextEntity(
            id: id,
            content: content,
            wpm: Int(wpm),
            fontSize: Int(fontSize),
            musicTrack: musicTrack,
            rating: rating,
            lastReadAt: lastReadAt,
            progressIndex: Int(progressIndex),
            sessionId: sessionId
        )
    }
    
    static func fromEntity(_ entity: StudyTextEntity) -> StudyTextDTO {
        return StudyTextDTO(
            id: entity.id,
            content: entity.content,
            wpm: Int32(entity.wpm),
            fontSize: Int32(entity.fontSize),
            musicTrack: entity.musicTrack,
            rating: entity.rating,
            lastReadAt: entity.lastReadAt,
            progressIndex: Int32(entity.progressIndex),
            sessionId: entity.sessionId
        )
    }
}
