//
//  TextEditSheet.swift
//  StudySprint
//

import SwiftUI

struct TextEditSheet: View {
    @Binding var text: String
    @Binding var isPresented: Bool
    @State private var tempText: String
    
    init(text: Binding<String>, isPresented: Binding<Bool>) {
        self._text = text
        self._isPresented = isPresented
        self._tempText = State(initialValue: text.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        Button("Limpiar todo") {
                            tempText = ""
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        
                        Button("Eliminar espacios extras") {
                            tempText = tempText.removingExtraSpaces()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Eliminar líneas vacías") {
                            tempText = tempText.removingEmptyLines()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal)
                }
                
                TextEditor(text: $tempText)
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
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        text = tempText
                        isPresented = false
                    }
                }
            }
        }
    }
}
