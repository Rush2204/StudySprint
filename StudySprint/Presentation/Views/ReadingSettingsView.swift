//
//  ReadingSettingsView.swift
//  StudySprint
//

import SwiftUI

struct ReadingSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var wpm: Double
    @Binding var fontSize: Double
    @Binding var isMetronomeEnabled: Bool 
    let onSave: () -> Void
    
    @State private var previewText = AppConstants.previewText
    @State private var isPreviewPlaying = false
    @State private var previewTimer: Timer?
    @State private var previewIndex = 0
    @State private var previewWords: [String] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section("Velocidad de Lectura") {
                    VStack(spacing: 15) {
                        HStack {
                            
                            Slider(value: $wpm, in: Double(AppConstants.minWPM)...Double(AppConstants.maxWPM), step: 50)
                            
                        }
                        
                        HStack {
                            Spacer()
                            Text("\(Int(wpm)) ppm")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.blue)
                            Spacer()
                        }
                        
                        HStack(spacing: 15) {
                            ForEach(AppConstants.wpmPresets, id: \.self) { speed in
                                Button("\(speed)") {
                                    withAnimation {
                                        wpm = Double(speed)
                                    }
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .tint(Int(wpm) == speed ? .blue : .gray)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
                
                Section("Tamaño de Letra") {
                    VStack(spacing: 15) {
                        HStack {
                            Text("A")
                                .font(.system(size: 12))
                            Slider(value: $fontSize, in: Double(AppConstants.minFontSize)...Double(AppConstants.maxFontSize), step: 1)
                            Text("A")
                                .font(.system(size: 32))
                        }
                        
                        HStack {
                            Spacer()
                            Text("\(Int(fontSize)) puntos")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.green)
                            Spacer()
                        }
                        
                        
                    }
                    .padding(.vertical, 5)
                }
                
                Section("Vista Previa de Lectura") {
                    VStack(spacing: 15) {
                        Text(previewText)
                            .font(.system(size: CGFloat(fontSize), weight: .medium))
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(12)
                            .animation(.easeInOut(duration: 0.1), value: previewText)
                        
                        HStack(spacing: 30) {
                            Button {
                                if isPreviewPlaying {
                                    stopPreview()
                                } else {
                                    startPreview()
                                }
                            } label: {
                                Label(isPreviewPlaying ? "Reproduciendo..." : "Probar Velocidad",
                                      systemImage: isPreviewPlaying ? "pause.circle" : "play.circle")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(isPreviewPlaying ? Color.orange : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            

                        }
                    }
                    .padding(.vertical, 5)
                }
                Section("Metrónomo") {
                    Toggle("Activar metrónomo", isOn: $isMetronomeEnabled)
                        .tint(.orange)
                    
                    if isMetronomeEnabled {
                        Text("Sonará un tick por cada palabra a \(Int(wpm)) ppm")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Section {
                    Text("Sugerencia: Empieza con 250 ppm y aumenta gradualmente")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        stopPreview()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        stopPreview()
                        onSave()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            previewWords = AppConstants.previewText.words
        }
        .onDisappear {
            stopPreview()
        }
    }
    
    private func startPreview() {
        guard !previewWords.isEmpty else { return }
        isPreviewPlaying = true
        previewIndex = 0
        previewText = previewWords[0]
        
        previewTimer = Timer.scheduledTimer(withTimeInterval: 60.0 / wpm, repeats: true) { _ in
            if previewIndex + 1 < previewWords.count {
                previewIndex += 1
                withAnimation {
                    previewText = previewWords[previewIndex]
                }
            } else {
                stopPreview()
                previewText = AppConstants.previewText
                previewIndex = 0
            }
        }
    }
    
    private func stopPreview() {
        previewTimer?.invalidate()
        previewTimer = nil
        isPreviewPlaying = false
        previewText = AppConstants.previewText
        previewIndex = 0
    }
}
