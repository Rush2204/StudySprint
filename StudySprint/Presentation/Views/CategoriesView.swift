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
                } else {
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
                        TextField("Nombre", text: $newCategoryName)
                        TextField("Descripción (opcional)", text: $newCategoryDescription)
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
