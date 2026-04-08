//
//  StudySprintApp.swift
//  StudySprint
//
//  Created by Rene Torres on 8/4/26.
//

import SwiftUI
import CoreData

@main
struct StudySprintApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
