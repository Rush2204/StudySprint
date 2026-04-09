//
//  RSVPReaderView.swift
//  StudySprint
//

import SwiftUI

struct RSVPReaderView: View {
    let sessionId: UUID
    let textContent: String
    let wpm: Int
    let fontSize: Int
    let onComplete: (Double) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RSVPViewModel
    @State private var showingRating = false
    @State private var showingQuickSettings = false
    @State private var rating: Double = 0
    @State private var currentWord = ""
    @State private var currentWPM: Int
    @State private var currentFontSize: Int
    
    init(sessionId: UUID, textContent: String, wpm: Int, fontSize: Int, onComplete: @escaping (Double) -> Void) {
        self.sessionId = sessionId
        self.textContent = textContent
        self.wpm = wpm
        self.fontSize = fontSize
        self.onComplete = onComplete
        _currentWPM = State(initialValue: wpm)
        _currentFontSize = State(initialValue: fontSize)
        _viewModel = StateObject(wrappedValue: RSVPViewModel(words: textContent.words, wpm: wpm))
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
                
                Text(currentWord)
                    .font(.system(size: CGFloat(currentFontSize), weight: .medium, design: .rounded))
                    .foregroundColor(.white)
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
                            .font(.caption)
                    }
                    
                    Button {
                        viewModel.pause()
                        showingRating = true
                    } label: {
                        Label("Finalizar", systemImage: "checkmark.circle")
                            .font(.caption)
                    }
                }
                .foregroundColor(.gray)
                .padding(.bottom)
            }
        }
        .onAppear {
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
        }
    }
}

