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



