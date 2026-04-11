//
//  RSVPReaderView.swift
//  StudySprint
//

import SwiftUI

struct RSVPReaderView: View {
    let sessionId: UUID
    let textContent: String
    @Binding var wpm: Int
    let fontSize: Int
    let isMetronomeEnabled: Bool
    let onComplete: (Double) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RSVPViewModel
    @StateObject private var metronome = MetronomeService()
    @State private var showingRating = false
    @State private var showingQuickSettings = false
    @State private var rating: Double = 0
    @State private var currentWord = ""
    @State private var currentWPM: Int
    @State private var currentFontSize: Int
    
    init(sessionId: UUID, textContent: String, wpm: Binding<Int>, fontSize: Int,isMetronomeEnabled enabled: Bool, onComplete: @escaping (Double) -> Void) {
        self.sessionId = sessionId
        self.textContent = textContent
        self._wpm = wpm
        self.fontSize = fontSize
        self.isMetronomeEnabled = enabled
        self.onComplete = onComplete
        _currentWPM = State(initialValue: wpm.wrappedValue)
        _currentFontSize = State(initialValue: fontSize)
        _viewModel = StateObject(wrappedValue: RSVPViewModel(words: textContent.words, wpm: wpm.wrappedValue))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Lectura")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("\(currentWPM) ppm")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    
                }
                .padding(.horizontal)
                .padding(.top)
                
                Spacer()
                
                HStack(spacing: 0) {
                     Text(viewModel.highlightedWord(currentWord).before)
                          .foregroundColor(.white)
                     Text(viewModel.highlightedWord(currentWord).middle)
                          .foregroundColor(.red)
                     Text(viewModel.highlightedWord(currentWord).after)
                          .foregroundColor(.white)
                }
                .font(.system(size: CGFloat(currentFontSize), weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .animation(.easeInOut(duration: 0.1), value: currentWord)
                                
                 Spacer()
                
                VStack(spacing: 5) {
                    ProgressView(value: viewModel.progress)
                        .tint(.blue)
                    Text("\(Int(viewModel.progress * 100))% completado")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                HStack(spacing: 40) {
                    Button {
                        viewModel.previousWord()
                    } label: {
                        Image(systemName: "backward.fill")
                            .font(.title)
                    }
                    
                    Button {
                        if viewModel.isPlaying {
                            viewModel.pause()
                        } else {
                            viewModel.play()
                        }
                    } label: {
                        Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 60))
                    }
                    
                    Button {
                        viewModel.nextWord()
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.title)
                    }
                    
                }
                .foregroundColor(.white)
                .padding(.bottom, 30)
                
                HStack(spacing: 30) {
                    Button {
                        viewModel.restart()
                    } label: {
                        Label("Reiniciar", systemImage: "arrow.counterclockwise")
                            .font(.system(size: 17))
                    }
                    
                    Button {
                        viewModel.pause()
                        showingRating = true
                    } label: {
                        Label("Finalizar", systemImage: "checkmark.circle")
                            .font(.system(size: 17))
                    }
                }
                .foregroundColor(.gray)
                .padding(.bottom)
            }
        }
        .onAppear {
            currentWord = viewModel.currentWord
            currentWPM = viewModel.currentWPM 
            
            // Configurar metrónomo según preferencia del usuario
                        metronome.setEnabled(isMetronomeEnabled)
                        metronome.setBPM(currentWPM)
                        
                        // Si el metrónomo está activado y la lectura está reproduciendo, iniciar
                        if isMetronomeEnabled && viewModel.isPlaying {
                            metronome.start()
                        }
            
            currentWord = viewModel.currentWord
            viewModel.onWordChange = { word in
                currentWord = word
            }
            viewModel.onComplete = {
                showingRating = true
            }
            viewModel.play()
        }
        .onDisappear {
            viewModel.pause()
            metronome.stop()
        }
        .onChange(of: wpm) { newWPM in
            currentWPM = newWPM
            viewModel.updateWPM(newWPM)
            metronome.setBPM(newWPM)
        }

        .onChange(of: currentWPM) { newValue in
            metronome.setBPM(newValue)
        }

        .onChange(of: viewModel.isPlaying) { isPlaying in
            if isPlaying && isMetronomeEnabled {
                metronome.start()
            } else {
                metronome.stop()
            }
        }
        .sheet(isPresented: $showingRating) {
            NavigationView {
                Form {
                    Section {
                        VStack(spacing: 20) {
                            Text("Califica tu comprensión")
                                .font(.headline)
                            
                            HStack {
                                Text("0")
                                Slider(value: $rating, in: 0...10, step: 0.5)
                                Text("10")
                            }
                            
                            Text("\(rating, specifier: "%.1f") / 10")
                                .font(.title2)
                                .bold()
                        }
                        .padding()
                    }
                }
                .navigationTitle("Calificar")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") {
                            showingRating = false
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Guardar") {
                            onComplete(rating)
                            showingRating = false
                            dismiss()
                        }
                    }
                }
            }
        }.toolbar(.hidden, for: .tabBar)
            
    }
}

