//
//  SessionsView.swift
//  StudySprint
//

import SwiftUI
internal import CoreData

struct SessionsView: View {
    let categoryId: UUID
    @StateObject private var viewModel: SessionViewModel
    @State private var showingAddSession = false
    @State private var sessionToEdit: SessionEntity?
    @State private var newSessionName = ""
    @State private var newSessionDescription = ""
    
    init(categoryId: UUID) {
        self.categoryId = categoryId
        let repository = SessionRepository(dataSource: LocalDataSource(context: PersistenceController.shared.container.viewContext))
        let useCases = SessionUseCases(repository: repository)
        _viewModel = StateObject(wrappedValue: SessionViewModel(useCases: useCases, categoryId: categoryId))
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Cargando...")
            } else {
                List {
                    ForEach(viewModel.sessions) { session in
                        NavigationLink(destination: TextView(sessionId: session.id)) {
                            VStack(alignment: .leading) {
                                Text(session.name)
                                    .font(.headline)
                                if let desc = session.description, !desc.isEmpty {
                                    Text(desc)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                viewModel.deleteSession(session)
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                            
                            Button {
                                sessionToEdit = session
                                newSessionName = session.name
                                newSessionDescription = session.description ?? ""
                                showingAddSession = true
                            } label: {
                                Label("Editar", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Sesiones")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    newSessionName = ""
                    newSessionDescription = ""
                    sessionToEdit = nil
                    showingAddSession = true
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
        .sheet(isPresented: $showingAddSession) {
            NavigationView {
                Form {
                    TextField("Nombre", text: $newSessionName)
                    TextField("Descripción (opcional)", text: $newSessionDescription)
                }
                .navigationTitle(sessionToEdit == nil ? "Nueva Sesión" : "Editar Sesión")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") {
                            showingAddSession = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Guardar") {
                            if let edit = sessionToEdit {
                                viewModel.updateSession(edit, name: newSessionName, description: newSessionDescription)
                            } else {
                                viewModel.createSession(name: newSessionName, description: newSessionDescription)
                            }
                            showingAddSession = false
                        }
                        .disabled(newSessionName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
        }
    }
}
