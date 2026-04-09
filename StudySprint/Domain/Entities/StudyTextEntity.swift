//
//  StudyTextEntity.swift
//  StudySprint
//

import Foundation

struct StudyTextEntity: Identifiable, Equatable {
    let id: UUID
    var content: String
    var wpm: Int
    var fontSize: Int
    var musicTrack: String?
    var rating: Double
    var lastReadAt: Date?
    var progressIndex: Int
    let sessionId: UUID
    
    init(id: UUID = UUID(), content: String, wpm: Int = 250, fontSize: Int = 24,
         musicTrack: String? = nil, rating: Double = 0, lastReadAt: Date? = nil,
         progressIndex: Int = 0, sessionId: UUID) {
        self.id = id
        self.content = content
        self.wpm = wpm
        self.fontSize = fontSize
        self.musicTrack = musicTrack
        self.rating = rating
        self.lastReadAt = lastReadAt
        self.progressIndex = progressIndex
        self.sessionId = sessionId
    }
}
