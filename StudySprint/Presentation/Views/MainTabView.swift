//
//  MainTabView.swift
//  StudySprint
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CategoriesView()
                .tabItem {
                    Label("Materias", systemImage: "folder")
                }
                .tag(0)
            
            StatisticsView()
                .tabItem {
                    Label("Estadísticas", systemImage: "chart.bar")
                }
                .tag(1)
        }
    }
}

#Preview {
    MainTabView()
}
