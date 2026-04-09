//
//  RSVPViewModel.swift
//  StudySprint
//

import SwiftUI
import Combine

@MainActor
class RSVPViewModel: ObservableObject {
    @Published var currentWord = ""
    @Published var isPlaying = false
    @Published var progress: Double = 0
    @Published var currentIndex = 0
    @Published var currentWPM: Int
    
    private let words: [String]
    private var interval: TimeInterval
    private var timer: Timer?
    
    var onWordChange: ((String) -> Void)?
    var onComplete: (() -> Void)?
    
    init(words: [String], wpm: Int) {
        self.words = words
        self.currentWPM = wpm
        self.interval = 60.0 / Double(wpm)
        if !words.isEmpty {
            self.currentWord = words[0]
        }
    }
    
    func play() {
        guard !isPlaying, currentIndex < words.count else { return }
        isPlaying = true
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.nextWord()
            }
        }
    }
    
    func pause() {
        timer?.invalidate()
        timer = nil
        isPlaying = false
    }
    
    func nextWord() {
        if currentIndex + 1 < words.count {
            currentIndex += 1
            updateCurrentWord()
        } else if currentIndex + 1 == words.count {
            currentIndex += 1
            updateCurrentWord()
            pause()
            onComplete?()
        }
    }
    
    func previousWord() {
        if currentIndex > 0 {
            currentIndex -= 1
            updateCurrentWord()
        }
    }
    
    func restart() {
        pause()
        currentIndex = 0
        updateCurrentWord()
        play()
    }
    
    func updateWPM(_ newWPM: Int) {
        currentWPM = newWPM
        interval = 60.0 / Double(newWPM)
        
        let wasPlaying = isPlaying
        pause()
        
        if wasPlaying {
            play()
        }
    }
    
    private func updateCurrentWord() {
        if currentIndex < words.count {
            currentWord = words[currentIndex]
            progress = Double(currentIndex + 1) / Double(words.count)
            onWordChange?(currentWord)
        } else {
            currentWord = ""
            progress = 1.0
        }
    }
}
