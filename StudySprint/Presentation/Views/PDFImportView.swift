//
//  PDFImportView.swift
//  StudySprint
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct PDFImportView: View {
    @Environment(\.dismiss) private var dismiss
    let onTextExtracted: (String?) -> Void
    
    @State private var showingDocumentPicker = false
    @State private var isLoading = false
    @State private var isProcessingOCR = false
    @State private var errorMessage: String?
    @State private var selectedPDF: PDFDocument?
    @State private var pageRange = "1-"
    @State private var totalPages = 0
    @State private var processingProgress = 0.0
    @State private var currentPageProcessing = 0
    @State private var showingPreview = false
    @State private var extractedText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isLoading {
                    VStack(spacing: 15) {
                        ProgressView("Procesando PDF...")
                        if isProcessingOCR {
                            Text("Procesando página \(currentPageProcessing) de \(totalPages)")
                                .font(.caption)
                            ProgressView(value: processingProgress, total: Double(totalPages))
                        }
                    }
                    .padding()
                } else if let pdf = selectedPDF {
                    VStack(spacing: 15) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("PDF cargado")
                                    .font(.headline)
                                Text("Total de páginas: \(totalPages)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button("Cambiar PDF") {
                                selectedPDF = nil
                                pageRange = "1-"
                                showingDocumentPicker = true
                            }
                            .font(.caption)
                        }
                        .padding(.horizontal)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Selección de páginas")
                                .font(.headline)
                            TextField("Ej: 1-10, 15, 20-25", text: $pageRange)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Text("Puedes usar rangos (1-10) o páginas individuales (1,3,5)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        Divider()
                        
                        Button {
                            extractTextWithPreview()
                        } label: {
                            Label("Extraer y Previsualizar", systemImage: "eye.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .disabled(pageRange.isEmpty)
                    }
                    .padding(.vertical)
                } else {
                    VStack(spacing: 25) {
                        Image(systemName: "doc.badge.plus")
                            .font(.system(size: 70))
                            .foregroundColor(.blue)
                        Text("Selecciona un archivo PDF")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Soporta PDFs con texto seleccionable y PDFs escaneados (OCR)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Button("Seleccionar PDF") {
                            showingDocumentPicker = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
                
                if let error = errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .navigationTitle("Importar PDF")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                        onTextExtracted(nil)
                    }
                }
            }
            .fileImporter(
                isPresented: $showingDocumentPicker,
                allowedContentTypes: [UTType.pdf],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    processPDF(at: url)
                case .failure(let error):
                    errorMessage = "Error: \(error.localizedDescription)"
                }
            }
            .sheet(isPresented: $showingPreview) {
                TextPreviewView(
                    extractedText: extractedText,
                    onConfirm: { finalText in
                        onTextExtracted(finalText)
                        dismiss()
                    },
                    onCancel: {
                        showingPreview = false
                    }
                )
            }
        }
    }
    
    private func processPDF(at url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            errorMessage = "No se pudo acceder al archivo"
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        guard let pdf = PDFDocument(url: url) else {
            errorMessage = "No se pudo cargar el PDF"
            return
        }
        
        selectedPDF = pdf
        totalPages = pdf.pageCount
        pageRange = "1-\(totalPages)"
    }
    
    private func extractTextWithPreview() {
        guard let pdf = selectedPDF else { return }
        
        isLoading = true
        isProcessingOCR = true
        errorMessage = nil
        processingProgress = 0
        currentPageProcessing = 0
        
        let pages = PDFParser.parsePageRange(pageRange, totalPages: totalPages)
        let totalPagesToProcess = pages.count
        
        Task {
            var allText = ""
            var processedPages = 0
            
            for pageNumber in pages {
                await MainActor.run {
                    currentPageProcessing = pageNumber
                    processingProgress = Double(processedPages) / Double(totalPagesToProcess)
                }
                
                guard let page = pdf.page(at: pageNumber - 1) else { continue }
                
                var pageText = ""
                if let directText = page.string, !directText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    pageText = directText
                } else {
                    pageText = await PDFParser.extractTextFromPageWithOCR(page: page, pageNumber: pageNumber)
                }
                
                if !pageText.isEmpty {
                    allText += "--- Página \(pageNumber) ---\n"
                    allText += pageText
                    allText += "\n\n"
                }
                
                processedPages += 1
                await MainActor.run {
                    processingProgress = Double(processedPages) / Double(totalPagesToProcess)
                }
            }
            
            await MainActor.run {
                isLoading = false
                isProcessingOCR = false
                
                if allText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    errorMessage = "No se pudo extraer texto"
                } else {
                    extractedText = allText
                    showingPreview = true
                }
            }
        }
    }
}
