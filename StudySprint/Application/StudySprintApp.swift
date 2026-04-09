//
//  StudySprintApp.swift
//  StudySprint
//

import SwiftUI
internal import CoreData

@main
struct StudySprintApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
