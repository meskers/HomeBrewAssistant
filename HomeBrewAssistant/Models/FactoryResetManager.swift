import Foundation
import CoreData
import SwiftUI
import UserNotifications

/// Manages factory reset functionality to clean user data for fresh App Store downloads
class FactoryResetManager: ObservableObject {
    static let shared = FactoryResetManager()
    
    @Published var isResetting = false
    @Published var resetProgress: Double = 0.0
    
    private init() {}
    
    /// Perform complete factory reset while preserving default recipes
    func performFactoryReset() async throws {
        await MainActor.run {
            isResetting = true
            resetProgress = 0.0
        }
        
        print("🧹 Starting factory reset...")
        
        // 1. Clear UserDefaults (except system preferences)
        await clearUserDefaults()
        await updateProgress(0.1)
        
        // 2. Clear all CoreData user-created content (preserve default recipes)
        try await clearCoreDataUserContent()
        await updateProgress(0.3)
        
        // 3. Clear Photos and cached images
        await clearPhotosAndCache()
        await updateProgress(0.5)
        
        // 4. Clear Analytics and Brew Sessions
        await clearAnalyticsData()
        await updateProgress(0.7)
        
        // 5. Clear Version History and Reset to Fresh State
        await clearVersionHistory()
        await updateProgress(0.8)
        
        // 6. Clear Notifications
        await clearNotifications()
        await updateProgress(0.9)
        
        // 7. Reset onboarding to show for fresh users
        await resetOnboardingState()
        await updateProgress(1.0)
        
        print("✅ Factory reset completed successfully!")
        
        await MainActor.run {
            isResetting = false
        }
    }
    
    // MARK: - Individual Reset Functions
    
    private func clearUserDefaults() async {
        await MainActor.run {
            let userDefaults = UserDefaults.standard
            
            // Clear ALL user data but reset essential settings to fresh defaults
            let allKeys = Array(userDefaults.dictionaryRepresentation().keys)
            
            // Keys to keep (system settings)
            let keysToKeep = [
                "AppleLanguages",
                "AppleLocale",
                "NSLanguages"
            ]
            
            // Remove all user data
            for key in allKeys {
                if !keysToKeep.contains(key) && !key.hasPrefix("Apple") && !key.hasPrefix("NS") {
                    userDefaults.removeObject(forKey: key)
                }
            }
            
            // Set fresh defaults for a perfect App Store experience
            userDefaults.set(true, forKey: "useMetricSystem")
            userDefaults.set(false, forKey: "darkMode")
            userDefaults.set(true, forKey: "notificationsEnabled")
            userDefaults.set(20.0, forKey: "defaultBatchSize")
            userDefaults.set(75.0, forKey: "defaultEfficiency")
            
            // Reset onboarding to show for new users
            userDefaults.set(false, forKey: "hasCompletedOnboarding")
            
            // Reset default recipes installation flag so they get installed again after onboarding
            DefaultRecipeInstaller.resetInstallationFlag()
            
            userDefaults.synchronize()
            print("🗑️ UserDefaults completely reset to fresh state")
        }
    }
    
    private func clearCoreDataUserContent() async throws {
        let context = PersistenceController.shared.backgroundContext
        
        try await context.perform {
            // COMPLETE RESET: Delete ALL recipes and ingredients
            // This ensures a completely clean database for App Store downloads
            
            // 1. Delete ALL recipes (including defaults - they will be recreated)
            let recipeRequest: NSFetchRequest<NSFetchRequestResult> = DetailedRecipeModel.fetchRequest()
            let recipeBatchDelete = NSBatchDeleteRequest(fetchRequest: recipeRequest)
            recipeBatchDelete.resultType = .resultTypeObjectIDs
            try context.execute(recipeBatchDelete)
            
            // 2. Delete ALL ingredients
            let ingredientRequest: NSFetchRequest<NSFetchRequestResult> = Ingredient.fetchRequest()
            let ingredientBatchDelete = NSBatchDeleteRequest(fetchRequest: ingredientRequest)
            ingredientBatchDelete.resultType = .resultTypeObjectIDs
            try context.execute(ingredientBatchDelete)
            
            // 3. Save the clean state
            try context.save()
            
            // 4. Force Core Data to refresh the context to clear any cached data
            context.refreshAllObjects()
            
            print("🗑️ CoreData COMPLETELY WIPED - all recipes and ingredients deleted")
        }
        
        // 5. Also clear the main context
        await MainActor.run {
            let mainContext = PersistenceController.shared.container.viewContext
            mainContext.refreshAllObjects()
            print("🔄 Main context refreshed")
        }
    }
    
    private func clearPhotosAndCache() async {
        let photoManager = PhotoManager.shared
        
        // Clear all photos
        await MainActor.run {
            photoManager.capturedImages.removeAll()
        }
        
        // Clear photo directories
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosPath = documentsPath.appendingPathComponent("Photos")
        let cachesPath = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let thumbnailsPath = cachesPath.appendingPathComponent("PhotoThumbnails")
        
        try? fileManager.removeItem(at: photosPath)
        try? fileManager.removeItem(at: thumbnailsPath)
        
        // Recreate empty directories
        try? fileManager.createDirectory(at: photosPath, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: thumbnailsPath, withIntermediateDirectories: true)
        
        print("🗑️ Photos and cache cleared")
    }
    
    private func clearAnalyticsData() async {
        // Clear from UserDefaults directly - this affects all BrewAnalytics instances
        await MainActor.run {
            UserDefaults.standard.removeObject(forKey: "BrewAnalyticsData")
            UserDefaults.standard.removeObject(forKey: "brew_analytics_data")
            UserDefaults.standard.removeObject(forKey: "analytics_data")
            UserDefaults.standard.removeObject(forKey: "brewSessions")
            UserDefaults.standard.removeObject(forKey: "achievements")
            UserDefaults.standard.removeObject(forKey: "statistics")
            UserDefaults.standard.removeObject(forKey: "personalBests")
            UserDefaults.standard.removeObject(forKey: "currentStreak")
            
            // Clear any analytics related keys
            let allKeys = Array(UserDefaults.standard.dictionaryRepresentation().keys)
            for key in allKeys {
                if key.lowercased().contains("analytics") || 
                   key.lowercased().contains("brew") ||
                   key.lowercased().contains("achievement") ||
                   key.lowercased().contains("statistic") {
                    UserDefaults.standard.removeObject(forKey: key)
                }
            }
            
            UserDefaults.standard.synchronize()
        }
        
        print("🗑️ Analytics data cleared from UserDefaults")
    }
    
    private func clearVersionHistory() async {
        let versionManager = VersionManager.shared
        
        await MainActor.run {
            versionManager.versionHistory.removeAll()
            versionManager.clearCache()
        }
        
        // Remove from UserDefaults
        UserDefaults.standard.removeObject(forKey: "version_history")
        UserDefaults.standard.removeObject(forKey: "last_recorded_version")
        
        print("🗑️ Version history cleared")
    }
    
    private func clearNotifications() async {
        await MainActor.run {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
        
        print("🗑️ Notifications cleared")
    }
    
    private func resetOnboardingState() async {
        await MainActor.run {
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
            UserDefaults.standard.synchronize()
        }
        
        print("🔄 Onboarding state reset - will show for new users")
    }
    
    private func updateProgress(_ progress: Double) async {
        await MainActor.run {
            resetProgress = progress
        }
    }
    
    // MARK: - Quick Actions
    
    /// Reset only user preferences to defaults
    func resetUserPreferences() {
        let userDefaults = UserDefaults.standard
        
        userDefaults.removeObject(forKey: "useMetricSystem")
        userDefaults.removeObject(forKey: "darkMode")
        userDefaults.removeObject(forKey: "notificationsEnabled")
        userDefaults.removeObject(forKey: "defaultBatchSize")
        userDefaults.removeObject(forKey: "defaultEfficiency")
        
        userDefaults.synchronize()
        print("⚙️ User preferences reset to defaults")
    }
    
    /// Clear only analytics data
    func clearAnalyticsOnly() {
        UserDefaults.standard.removeObject(forKey: "BrewAnalyticsData")
        UserDefaults.standard.synchronize()
        print("📊 Analytics data cleared")
    }
    
    /// Clear only photos
    func clearPhotosOnly() {
        Task {
            await clearPhotosAndCache()
        }
    }
}

// MARK: - Supporting Data Models

struct FactoryResetOption: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let action: () -> Void
    let isDestructive: Bool
} 