//
//  TextView.swift
//  StudySprint
//

import SwiftUI
internal import CoreData

struct TextView: View {
    let sessionId: UUID
    @StateObject private var viewModel: TextViewModel
    @State private var showingTextInput = false
    @State private var showingPDFImport = false
    @State private var showingSettings = false
    @State private var manualText = ""
    @State private var navigateToReader = false
    @State private var showingEditSheet = false
    @State private var isMetronomeEnabled: Bool = false
    
    // 🔽 Bindings simplificados
    private var wpmBinding: Binding<Double> {
        Binding(
            get: { Double(viewModel.wpm) },
            set: { viewModel.wpm = Int($0) }
        )
    }
    
    private var fontSizeBinding: Binding<Double> {
        Binding(
            get: { Double(viewModel.fontSize) },
            set: { viewModel.fontSize = Int($0) }
        )
    }
    
    private var metronomeBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isMetronomeEnabled },
            set: { viewModel.toggleMetronome($0) }
        )
    }
    
    init(sessionId: UUID) {
        self.sessionId = sessionId
        let repository = TextRepository(dataSource: LocalDataSource(context: PersistenceController.shared.container.viewContext))
        let useCases = TextUseCases(repository: repository)
        _viewModel = StateObject(wrappedValue: TextViewModel(useCases: useCases, sessionId: sessionId))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView("Cargando...")
                } else if let text = viewModel.studyText {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Contenido:")
                            .font(.headline)
                        
                        Text(text.content.prefix(300))
                            .font(.body)
                            .foregroundColor(.gray)
                            .lineLimit(4)
                        
                        HStack {
                            Label("\(text.wpm) ppm", systemImage: "speedometer")
                            Spacer()
                            Label("\(text.fontSize)pt", systemImage: "textformat.size")
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        
                        HStack(spacing: 15) {
                            Button {
                                showingSettings = true
                            } label: {
                                Label("Configurar", systemImage: "slider.horizontal.3")
                                    .frame(maxWidth: .infinity)
                                    .padding(13)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            
                            Button {
                                navigateToReader = true
                            } label: {
                                Label("Iniciar Lectura", systemImage: "play.circle.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding(13)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        
                        if !text.content.hasPrefix("--- Página") {
                            Button {
                                showingEditSheet = true
                            } label: {
                                Label("Editar Texto", systemImage: "pencil")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        
                        Button(role: .destructive) {
                            viewModel.deleteText()
                        } label: {
                            Label("Eliminar Texto", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.2))
                                .foregroundColor(.red)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                VStack(spacing: 15) {
                    Text("Agregar contenido de estudio")
                        .font(.headline)
                    
                    Button {
                        manualText = ""
                        showingTextInput = true
                    } label: {
                        Label("Texto Manual", systemImage: "keyboard")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(12)
                    }
                    
                    Button {
                        showingPDFImport = true
                    } label: {
                        Label("Importar PDF", systemImage: "doc")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle("Texto")
        .sheet(isPresented: $showingTextInput) {
            NavigationView {
                TextEditor(text: $manualText)
                    .navigationTitle("Ingresar Texto")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancelar") {
                                showingTextInput = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Guardar") {
                                viewModel.saveManualText(manualText)
                                showingTextInput = false
                            }
                            .disabled(manualText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
            }
        }
        .sheet(isPresented: $showingPDFImport) {
            PDFImportView { extractedText in
                if let text = extractedText {
                    viewModel.savePDFText(text)
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            ReadingSettingsView(
                wpm: wpmBinding,
                fontSize: fontSizeBinding,
                isMetronomeEnabled: metronomeBinding,
                onSave: {
                    viewModel.saveSettings()  
                }
            )
        }
        .sheet(isPresented: $showingEditSheet) {
            TextEditView(originalText: viewModel.studyText?.content ?? "") { newText in
                viewModel.updateManualText(newText)
            }
        }
        .background(
            NavigationLink(
                destination: RSVPReaderView(
                    sessionId: sessionId,
                    textContent: viewModel.studyText?.content ?? "",
                    wpm: Binding(
                                get: { viewModel.wpm },
                                set: { newValue in
                                    viewModel.wpm = newValue
                                    viewModel.saveSettings()
                                }
                            ),
                    fontSize: viewModel.fontSize,
                    isMetronomeEnabled: viewModel.isMetronomeEnabled, 
                    onComplete: { rating in
                        if var text = viewModel.studyText {
                            text.rating = rating
                            text.lastReadAt = Date()
                            viewModel.updateText(text)
                        }
                    }
                ),
                isActive: $navigateToReader
            ) {
                EmptyView()
            }
        )
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
