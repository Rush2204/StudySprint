//
//  StatisticsView.swift
//  StudySprint
//

import SwiftUI
internal import CoreData
import Combine

struct StatisticsView: View {
    @StateObject private var viewModel: StatisticsViewModel
    
    init() {
        let repository = TextRepository(dataSource: LocalDataSource(context: PersistenceController.shared.container.viewContext))
        let useCases = TextUseCases(repository: repository)
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(useCases: useCases))
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Cargando estadísticas...")
                } else if let stats = viewModel.statistics {
                    List {
                        Section("Resumen General") {
                            StatRow(title: "Total de sesiones", value: "\(stats.totalSessions)")
                            StatRow(title: "Promedio de calificación", value: String(format: "%.1f / 10", stats.averageRating))
                            StatRow(title: "Total de palabras leídas", value: "\(stats.totalWords)")
                            StatRow(title: "Tiempo total de lectura", value: stats.totalReadingTime)
                        }
                        
                        Section("Por Velocidad (WPM)") {
                            ForEach(stats.wpmStats.sorted(by: { $0.key < $1.key }), id: \.key) { wpm, data in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("\(wpm) ppm")
                                        .font(.headline)
                                    HStack {
                                        StatBadge(title: "Promedio", value: String(format: "%.1f", data.average))
                                        StatBadge(title: "Mayor", value: String(format: "%.1f", data.max))
                                        StatBadge(title: "Menor", value: String(format: "%.1f", data.min))
                                        StatBadge(title: "Sesiones", value: "\(data.count)")
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Completa tus primeras sesiones de lectura para ver estadísticas")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Estadísticas")
        }
        .onAppear {
            viewModel.loadStatistics()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

// MARK: - Supporting Views
struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

struct StatBadge: View {
    let title: String
    let value: String
    
    var body: some View {
        Text("\(title): \(value)")
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
    }
}

// MARK: - Statistics ViewModel
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
        let avgWPM = texts.reduce(0.0) { $0 + Double($1.wpm) } / Double(texts.count)
        let minutes = Double(totalWords) / avgWPM
        
        if minutes < 60 {
            return String(format: "%.0f minutos", minutes)
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes.truncatingRemainder(dividingBy: 60)
            return String(format: "%.0f h %.0f min", hours, remainingMinutes)
        }
    }
}

// MARK: - Data Structures
struct StatisticsData {
    let totalSessions: Int
    let averageRating: Double
    let totalWords: Int
    let totalReadingTime: String
    let wpmStats: [Int: WPMStatistics]
}

struct WPMStatistics {
    let average: Double
    let min: Double
    var max: Double
    let count: Int
}

struct WPMStatData {
    var count: Int
    var min: Double
    var max: Double
    var total: Double
}
