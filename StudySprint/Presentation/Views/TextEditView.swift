//
//  TextEditView.swift
//  StudySprint
//

import SwiftUI

struct TextEditView: View {
    @Environment(\.dismiss) private var dismiss
    let originalText: String
    let onSave: (String) -> Void
    
    @State private var editedText: String
    
    init(originalText: String, onSave: @escaping (String) -> Void) {
        self.originalText = originalText
        self.onSave = onSave
        _editedText = State(initialValue: originalText)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $editedText)
                    .font(.body)
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .padding()
            }
            .navigationTitle("Editar Texto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSave(editedText)
                        dismiss()
                    }
                    .disabled(editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
