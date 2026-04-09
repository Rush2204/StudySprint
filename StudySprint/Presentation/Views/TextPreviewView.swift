//
//  TextPreviewView.swift
//  StudySprint
//

import SwiftUI

struct TextPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let extractedText: String
    let onConfirm: (String) -> Void
    let onCancel: () -> Void
    
    @State private var editableText: String
    @State private var showingEditSheet = false
    
    init(extractedText: String, onConfirm: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
        self.extractedText = extractedText
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        _editableText = State(initialValue: extractedText)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "doc.text.magnifyingglass")
                            .foregroundColor(.blue)
                        Text("Vista Previa del Texto Extraído")
                            .font(.headline)
                    }
                    
                    HStack(spacing: 15) {
                        Label("\(editableText.count) caracteres", systemImage: "character")
                            .font(.caption)
                        Label("\(editableText.words.count) palabras", systemImage: "word")
                            .font(.caption)
                    }
                    .foregroundColor(.gray)
                    
                    Divider()
                }
                .padding()
                
                ScrollView {
                    Text(editableText)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal)
                
                VStack(spacing: 12) {
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
                    
                    HStack(spacing: 15) {
                        Button {
                            onCancel()
                            dismiss()
                        } label: {
                            Text("Cancelar")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.red)
                                .cornerRadius(12)
                        }
                        
                        Button {
                            onConfirm(editableText)
                            dismiss()
                        } label: {
                            Text("Aceptar y Guardar")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Previsualizar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        onCancel()
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                TextEditSheet(text: $editableText, isPresented: $showingEditSheet)
            }
        }
    }
}
