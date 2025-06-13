import SwiftUI

@main
struct HomeBrewAssistantApp: App {
    // 1. Voeg de PersistenceController toe
    let persistenceController = PersistenceController.shared
    
    // 2. Voeg LocalizationManager toe
    @StateObject private var localizationManager = LocalizationManager.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(localizationManager)
        }
    }
}
