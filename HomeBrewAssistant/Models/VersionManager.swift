import Foundation
import SwiftUI

/// Manages app versioning, changelog, and version-related functionality
class VersionManager: ObservableObject {
    static let shared = VersionManager()
    
    @Published var versionHistory: [VersionEntry] = []
    @Published var isCheckingVersion = false
    
    private let cache = NSCache<NSString, NSArray>()
    private let cacheKey = "version_history_cache"
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Version Information
    
    /// Current app version from Bundle
    var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }
    
    /// Current build number from Bundle
    var currentBuildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }
    
    /// Full version string (e.g., "1.2.3 (45)")
    var fullVersionString: String {
        "\(currentVersion) (\(currentBuildNumber))"
    }
    
    /// Semantic version components
    var versionComponents: (major: Int, minor: Int, patch: Int) {
        let components = currentVersion.split(separator: ".").compactMap { Int($0) }
        return (
            major: components.count > 0 ? components[0] : 1,
            minor: components.count > 1 ? components[1] : 0,
            patch: components.count > 2 ? components[2] : 0
        )
    }
    
    // MARK: - Version History & Changelog
    
    private init() {
        loadVersionHistory()
    }
    
    /// Load version history from local storage or defaults
    private func loadVersionHistory() {
        // Try to load from cache first
        if let cached = cache.object(forKey: cacheKey as NSString) as? [VersionEntry] {
            self.versionHistory = cached
            return
        }
        
        // Load from UserDefaults if not in cache
        if let data = userDefaults.data(forKey: "version_history"),
           let decoded = try? JSONDecoder().decode([VersionEntry].self, from: data) {
            self.versionHistory = decoded
            // Cache the loaded data
            cache.setObject(decoded as NSArray, forKey: cacheKey as NSString)
        }
    }
    
    /// Save version history to UserDefaults
    private func saveVersionHistory() {
        if let encoded = try? JSONEncoder().encode(versionHistory) {
            userDefaults.set(encoded, forKey: "version_history")
            // Update cache
            cache.setObject(versionHistory as NSArray, forKey: cacheKey as NSString)
        }
    }
    
    /// Add a new version entry
    func addVersionEntry(_ entry: VersionEntry) {
        versionHistory.insert(entry, at: 0) // Add to beginning (newest first)
        saveVersionHistory()
    }
    
    /// Check if this is a new version and add entry if needed
    func checkForNewVersion() async {
        await MainActor.run {
            isCheckingVersion = true
        }
        
        do {
            // Simulate network delay for smoother UI
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            let lastRecordedVersion = userDefaults.string(forKey: "last_recorded_version") ?? "0.0.0"
            
            if currentVersion != lastRecordedVersion {
                // This is a new version, add entry
                let newEntry = VersionEntry(
                    version: currentVersion,
                    buildNumber: currentBuildNumber,
                    releaseDate: Date(),
                    changes: await getChangesForVersion(currentVersion),
                    type: determineVersionType(from: lastRecordedVersion, to: currentVersion)
                )
                
                await MainActor.run {
                    addVersionEntry(newEntry)
                    userDefaults.set(currentVersion, forKey: "last_recorded_version")
                    print("🎉 New version detected: \(fullVersionString)")
                }
            }
        } catch {
            print("Error checking version: \(error)")
        }
        
        await MainActor.run {
            isCheckingVersion = false
        }
    }
    
    /// Get changes for a specific version
    private func getChangesForVersion(_ version: String) async -> [String] {
        // In a real app, this would fetch from a server
        // For now, return placeholder changes
        return [
            "Verbeterde prestaties",
            "Bug fixes en stabiliteitsverbeteringen",
            "Nieuwe functies toegevoegd"
        ]
    }
    
    /// Determine version type based on semantic versioning
    private func determineVersionType(from oldVersion: String, to newVersion: String) -> VersionType {
        let oldComponents = oldVersion.split(separator: ".").compactMap { Int($0) }
        let newComponents = newVersion.split(separator: ".").compactMap { Int($0) }
        
        guard oldComponents.count >= 3 && newComponents.count >= 3 else { return .patch }
        
        if newComponents[0] > oldComponents[0] {
            return .major
        } else if newComponents[1] > oldComponents[1] {
            return .minor
        } else {
            return .patch
        }
    }
    
    /// Get default version history
    private func getDefaultVersionHistory() -> [VersionEntry] {
        return [
            VersionEntry(
                version: "1.1.0",
                buildNumber: "3",
                releaseDate: Date(),
                changes: [
                    "🎉 MAJOR UPDATE: World-Class Recipe Collection",
                    "🏆 50+ Award-Winning Recipes from Master Brewers",
                    "🇳🇱 Authentic Dutch Beer Styles (Nederlandse Klassiekers)",
                    "🌍 International Favorites & Commercial Clones",
                    "✨ Beautiful Onboarding Experience for New Users",
                    "📊 Recipe Success Rates & Difficulty Indicators",
                    "🥇 Gold Medal Competition Winners Included",
                    "🔧 Professional Brewing Calculator Suite",
                    "🎨 Enhanced UI/UX for Premium Experience",
                    "📱 Complete Dutch & English Localization",
                    "💼 Export/Import with BeerXML Standard",
                    "🤖 AI Recipe Generator Foundation",
                    "📸 Photo Documentation System",
                    "📈 Advanced Brewing Analytics",
                    "⭐ Optimized for 5-Star App Store Rating"
                ],
                type: .major
            ),
            VersionEntry(
                version: "1.0.1",
                buildNumber: "2",
                releaseDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
                changes: [
                    "🐛 Fixed critical localization issues",
                    "🎨 Improved UI consistency across all views",
                    "🔧 Enhanced calculator accuracy",
                    "📱 Better iPad layout support",
                    "⚡ Performance optimizations"
                ],
                type: .patch
            ),
            VersionEntry(
                version: "1.0.0",
                buildNumber: "1", 
                releaseDate: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
                changes: [
                    "🎉 Initial Release - HomeBrewAssistant",
                    "📖 Basic Recipe Management",
                    "🧮 Core Brewing Calculators (ABV, IBU, SRM)",
                    "⏱️ Brewing Timer System",
                    "📝 Ingredients Inventory",
                    "🌍 Dutch & English Language Support",
                    "🎨 Beautiful Modern Interface",
                    "📱 Native iOS SwiftUI Application"
                ],
                type: .major
            )
        ]
    }
    
    // MARK: - Version Comparison
    
    /// Compare two version strings
    func compareVersions(_ version1: String, _ version2: String) -> ComparisonResult {
        return version1.compare(version2, options: .numeric)
    }
    
    /// Check if current version is newer than given version
    func isNewerThan(_ version: String) -> Bool {
        return compareVersions(currentVersion, version) == .orderedDescending
    }
    
    /// Get latest version entry
    var latestVersion: VersionEntry? {
        return versionHistory.first
    }
    
    /// Get version entries for display (grouped by type)
    var groupedVersionHistory: [VersionGroup] {
        let grouped = Dictionary(grouping: versionHistory) { entry in
            "\(entry.type.rawValue.capitalized) Updates"
        }
        
        return grouped.map { key, value in
            VersionGroup(title: key, versions: value.sorted { $0.releaseDate > $1.releaseDate })
        }.sorted { group1, group2 in
            // Sort by most recent version in each group
            let date1 = group1.versions.first?.releaseDate ?? Date.distantPast
            let date2 = group2.versions.first?.releaseDate ?? Date.distantPast
            return date1 > date2
        }
    }
    
    /// Clear version history cache
    func clearCache() {
        cache.removeAllObjects()
    }
}

// MARK: - Data Models

/// Represents a version entry in the changelog
struct VersionEntry: Codable, Identifiable {
    var id: UUID
    let version: String
    let buildNumber: String
    let releaseDate: Date
    let changes: [String]
    let type: VersionType
    
    init(version: String, buildNumber: String, releaseDate: Date, changes: [String], type: VersionType) {
        self.id = UUID()
        self.version = version
        self.buildNumber = buildNumber
        self.releaseDate = releaseDate
        self.changes = changes
        self.type = type
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, version, buildNumber, releaseDate, changes, type
    }
    
    /// Formatted release date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: releaseDate)
    }
    
    /// Full version string
    var fullVersion: String {
        "\(version) (\(buildNumber))"
    }
}

/// Version type following semantic versioning
enum VersionType: String, Codable, CaseIterable {
    case major = "major"
    case minor = "minor" 
    case patch = "patch"
    
    var icon: String {
        switch self {
        case .major: return "star.fill"
        case .minor: return "plus.circle.fill"
        case .patch: return "wrench.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .major: return .purple
        case .minor: return .blue
        case .patch: return .green
        }
    }
    
    var description: String {
        switch self {
        case .major: return "Major Release"
        case .minor: return "Feature Update"
        case .patch: return "Bug Fix"
        }
    }
}

/// Grouped version entries for display
struct VersionGroup {
    let title: String
    let versions: [VersionEntry]
}

// MARK: - Version Utilities

extension Bundle {
    /// Get app name
    var appName: String {
        infoDictionary?["CFBundleName"] as? String ?? "HomeBrewAssistant"
    }
    
    /// Get bundle identifier
    var bundleId: String {
        bundleIdentifier ?? "com.meskersonline.HomeBrewAssistant"
    }
    
    /// Get copyright info
    var copyright: String {
        infoDictionary?["NSHumanReadableCopyright"] as? String ?? "© 2024 HomeBrewAssistant"
    }
} 