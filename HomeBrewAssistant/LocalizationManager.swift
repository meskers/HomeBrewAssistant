import Foundation
import SwiftUI

/// Manages app localization and language switching
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    /// Available languages in the app
    enum Language: String, CaseIterable, Identifiable {
        case dutch = "nl"
        case english = "en"
        
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .dutch: return "Nederlands"
            case .english: return "English"
            }
        }
        
        var flag: String {
            switch self {
            case .dutch: return "🇳🇱"
            case .english: return "🇬🇧"
            }
        }
    }
    
    @Published var currentLanguage: Language {
        didSet {
            saveLanguagePreference()
            updateBundle()
        }
    }
    
    private var bundle: Bundle?
    
    private init() {
        // Load saved language preference or use system default
        if let savedLanguageCode = UserDefaults.standard.string(forKey: "selected_language"),
           let language = Language(rawValue: savedLanguageCode) {
            self.currentLanguage = language
        } else {
            // Auto-detect system language
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            self.currentLanguage = Language(rawValue: systemLanguage) ?? .english
        }
        
        updateBundle()
    }
    
    /// Save language preference to UserDefaults
    private func saveLanguagePreference() {
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selected_language")
    }
    
    /// Update the bundle for localized strings
    private func updateBundle() {
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            print("⚠️ Could not find bundle for language: \(currentLanguage.rawValue)")
            self.bundle = Bundle.main
            return
        }
        self.bundle = bundle
        print("✅ Updated bundle to language: \(currentLanguage.rawValue)")
    }
    
    /// Get localized string for the given key
    func localized(_ key: String, arguments: CVarArg...) -> String {
        let currentBundle = bundle ?? Bundle.main
        let format = currentBundle.localizedString(forKey: key, value: nil, table: nil)
        
        // If we get the key back, it means the localization wasn't found
        if format == key {
            print("⚠️ Missing localization for key: '\(key)' in language: \(currentLanguage.rawValue)")
            // Fallback to English if not Dutch
            if currentLanguage != .english {
                if let englishPath = Bundle.main.path(forResource: "en", ofType: "lproj"),
                   let englishBundle = Bundle(path: englishPath) {
                    let englishFormat = englishBundle.localizedString(forKey: key, value: key, table: nil)
                    return String(format: englishFormat, arguments: arguments)
                }
            }
            return key
        }
        
        return String(format: format, arguments: arguments)
    }
    
    /// Change the app language
    func changeLanguage(to language: Language) {
        print("🌍 Changing language from \(currentLanguage.rawValue) to \(language.rawValue)")
        currentLanguage = language
        // Force a UI refresh by triggering objectWillChange
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    /// Check if the current language is Dutch
    var isDutch: Bool {
        currentLanguage == .dutch
    }
    
    /// Check if the current language is English
    var isEnglish: Bool {
        currentLanguage == .english
    }
}

/// String extension for easy localization
extension String {
    /// Get localized version of this string
    var localized: String {
        LocalizationManager.shared.localized(self)
    }
    
    /// Get localized version with format arguments
    func localized(with arguments: CVarArg...) -> String {
        LocalizationManager.shared.localized(self, arguments: arguments)
    }
} 