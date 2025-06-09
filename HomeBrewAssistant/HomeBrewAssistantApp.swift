//
//  HomeBrewAssistantApp.swift
//  HomeBrewAssistant
//
//  Created by Cor Meskers on 09/06/2025.
//

import SwiftUI

@main
struct HomeBrewAssistantApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
