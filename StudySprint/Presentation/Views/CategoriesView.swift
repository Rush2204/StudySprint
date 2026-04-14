//
//  CategoriesView.swift
//  StudySprint
//

import SwiftUI
internal import CoreData

struct CategoriesView: View {
    @StateObject private var viewModel: CategoryViewModel
    
    init() {
        let repository = CategoryRepository(dataSource: LocalDataSource(context: PersistenceController.shared.container.viewContext))
        let useCases = CategoryUseCases(repository: repository)
        _viewModel = StateObject(wrappedValue: CategoryViewModel(useCases: useCases))
    }
    
    @State private var showingAddCategory = false
    @State private var categoryToEdit: CategoryEntity?
    @State private var newCategoryName = ""
    @State private var newCategoryDescription = ""
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Cargando...")
                }else if viewModel.categories.isEmpty {
                    // HIG: Estado vacío informativo y accionable
                    ContentUnavailableView {
                        Label("Sin Materias", systemImage: "book.closed.fill")
                    } description: {
                        Text("Comienza añadiendo las materias que vas a estudiar este ciclo.")
                    }
                }
                else {
                    List {
                        ForEach(viewModel.categories) { category in
                            NavigationLink(destination: SessionsView(categoryId: category.id)) {
                                VStack(alignment: .leading) {
                                    Text(category.name)
                                        .font(.headline)
                                    if let desc = category.description, !desc.isEmpty {
                                        Text(desc)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    viewModel.deleteCategory(category)
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                                
                                Button {
                                    categoryToEdit = category
                                    newCategoryName = category.name
                                    newCategoryDescription = category.description ?? ""
                                    showingAddCategory = true
                                } label: {
                                    Label("Editar", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Materias")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        newCategoryName = ""
                        newCategoryDescription = ""
                        categoryToEdit = nil
                        showingAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .sheet(isPresented: $showingAddCategory) {
                NavigationView {
                    
                    Form {
                        Section {
                            TextField("Nombre", text: $newCategoryName)
                                .onChange(of: newCategoryName) { oldValue, newValue in
                                    if newValue.count > 70 { // Límite para nombre
                                        newCategoryName = String(newValue.prefix(70))
                                    }
                                }
                            
                            VStack(alignment: .trailing) {
                                TextField("Descripción (opcional)", text: $newCategoryDescription, axis: .vertical)
                                    .lineLimit(3...5)
                                    .onChange(of: newCategoryDescription) { oldValue, newValue in
                                        if newValue.count > 200 {
                                            newCategoryDescription = String(newValue.prefix(200))
                                        }
                                    }
                                
                                // Contador de caracteres dinámico
                                if !newCategoryDescription.isEmpty {
                                        Text("\(newCategoryDescription.count) / 200")
                                            .font(.caption2)
                                            .foregroundColor(newCategoryDescription.count >= 200 ? .red : .gray)
                                            .transition(.opacity)
                                    }

                            }
                        } footer: {
                            if newCategoryDescription.count >= 200 {
                                Text("Has alcanzado el límite máximo de caracteres.")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                    }
                    .navigationTitle(categoryToEdit == nil ? "Nueva Materia" : "Editar Materia")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancelar") {
                                showingAddCategory = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Guardar") {
                                if let edit = categoryToEdit {
                                    viewModel.updateCategory(edit, name: newCategoryName, description: newCategoryDescription)
                                } else {
                                    viewModel.createCategory(name: newCategoryName, description: newCategoryDescription)
                                }
                                showingAddCategory = false
                            }
                            .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CategoriesView()
}
