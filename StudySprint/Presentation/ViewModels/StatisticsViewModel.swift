//
//  StatisticsViewModel.swift
//  StudySprint
//
import SwiftUI
internal import CoreData
import Combine

@MainActor
class StatisticsViewModel: ObservableObject {
    @Published var statistics: StatisticsData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let useCases: TextUseCasesProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(useCases: TextUseCasesProtocol) {
        self.useCases = useCases
    }
    
    func loadStatistics() {
        isLoading = true
        useCases.getAllTexts()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] texts in
                self?.statistics = self?.calculateStatistics(from: texts)
            }
            .store(in: &cancellables)
    }
    
    private func calculateStatistics(from texts: [StudyTextEntity]) -> StatisticsData? {
        let completedTexts = texts.filter { $0.rating > 0 }
        guard !completedTexts.isEmpty else { return nil }
        
        var totalWords = 0
        var totalRating = 0.0
        var wpmStats: [Int: WPMStatData] = [:]
        
        for text in completedTexts {
            totalWords += text.content.words.count
            totalRating += text.rating
            let wpmKey = text.wpm
            
            var data = wpmStats[wpmKey] ?? WPMStatData(count: 0, min: 10, max: 0, total: 0)
            data.count += 1
            data.total += text.rating
            data.min = min(data.min, text.rating)
            data.max = max(data.max, text.rating)
            wpmStats[wpmKey] = data
        }
        
        let averageRating = totalRating / Double(completedTexts.count)
        let totalSessions = completedTexts.count
        
        let wpmStatsProcessed = wpmStats.mapValues { data in
            WPMStatistics(average: data.total / Double(data.count), min: data.min, max: data.max, count: data.count)
        }
        
        let totalReadingTime = calculateReadingTime(totalWords: totalWords, texts: completedTexts)
        
        return StatisticsData(
            totalSessions: totalSessions,
            averageRating: averageRating,
            totalWords: totalWords,
            totalReadingTime: totalReadingTime,
            wpmStats: wpmStatsProcessed
        )
    }
    
    private func calculateReadingTime(totalWords: Int, texts: [StudyTextEntity]) -> String {
        guard !texts.isEmpty, totalWords > 0 else { return "0:00" }
        
        let avgWPM = texts.reduce(0.0) { $0 + Double($1.wpm) } / Double(texts.count)
        let totalMinutes = Double(totalWords) / avgWPM
        
        // Convertimos todo a segundos totales para facilitar el cálculo
        let totalSeconds = Int(totalMinutes * 60)
        
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            // Formato H:MM:SS (ej: 1:05:24)
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            // Formato M:SS (ej: 1:34)
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}
