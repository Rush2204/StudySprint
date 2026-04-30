//
//  TextEditSheet.swift
//  StudySprint
//

import SwiftUI

struct TextEditSheet: View {
    @Binding var text: String
    @Binding var isPresented: Bool
    @State private var tempText: String
    
    // Configuración de la cuadrícula: 2 columnas de tamaño flexible
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    init(text: Binding<String>, isPresented: Binding<Bool>) {
        self._text = text
        self._isPresented = isPresented
        self._tempText = State(initialValue: text.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Área de edición
                TextEditor(text: $tempText)
                    .font(.body)
                    .padding(8)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .padding()
                
                // Sección de botones (aprox 1/4 de la pantalla)
                VStack(alignment: .leading, spacing: 15) {
                    // Título de la sección
                    Text("Opciones de limpieza")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    // Cuadrícula 2x2
                    LazyVGrid(columns: columns, spacing: 12) {
                        actionButton(
                            title: "Limpiar todo",
                            icon: "trash", // Icono representativo
                            color: .gray
                        ) {
                            tempText = ""
                        }
                        
                        actionButton(
                            title: "Eliminar espacios",
                            icon: "xmark", // Icono representativo
                            color: .gray
                        ) {
                            tempText = tempText.removingExtraSpaces()
                        }
                        
                        actionButton(
                            title: "Eliminar líneas",
                            icon: "text.alignleft", // Icono representativo
                            color: .gray
                        ) {
                            tempText = tempText.removingEmptyLines()
                        }
                        
                        actionButton(
                            title: "Quitar marcadores",
                            icon: "bookmark.slash", // Icono representativo
                            color: .gray
                        ) {
                            tempText = tempText.removingPageMarkers()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 25) // Espacio extra inferior para el área segura
                }
                // Limita esta sección a aprox 1/4 de la pantalla
                .frame(maxHeight: UIScreen.main.bounds.height / 3.8)
                .padding(.top, 10)
                .background(Color(UIColor.secondarySystemBackground)) // Fondo sutil para la zona de botones
            }
            .navigationTitle("Editar Texto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        text = tempText
                        isPresented = false
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    // Componente de botón personalizado actualizado
    @ViewBuilder
    private func actionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(.black) // Letra y icono negros
            .padding(.horizontal, 5)
            .frame(maxWidth: .infinity)
            .frame(height: 65) // Altura para mantener forma cuadrada/rectangular
            .background(Color(white: 0.9)) // Gris muy claro
            .cornerRadius(10) // Borde ligeramente redondeado
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1) // Borde sutil opcional
            )
        }
    }
}
