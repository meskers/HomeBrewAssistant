import SwiftUI

struct LanguageSettingsView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "globe")
                        .font(.system(size: 50))
                        .foregroundColor(.brewTheme)
                    
                    Text("language.change".localized)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("language.select.subtitle".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Language Options
                VStack(spacing: 15) {
                    ForEach(LocalizationManager.Language.allCases) { language in
                        LanguageOptionCard(
                            language: language,
                            isSelected: localizationManager.currentLanguage == language
                        ) {
                            localizationManager.changeLanguage(to: language)
                        }
                    }
                }
                
                Spacer()
                
                // Info about restart
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.secondary)
                        Text("language.update.info".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.primaryCard)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .navigationTitle("Language / Taal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("action.done".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct LanguageOptionCard: View {
    let language: LocalizationManager.Language
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // Flag and language name
                HStack(spacing: 12) {
                    Text(language.flag)
                        .font(.title2)
                    
                    VStack(alignment: .leading) {
                        Text(language.displayName)
                            .font(.headline)
                            .foregroundColor(.labelPrimary)
                        
                        Text(language == .dutch ? "language.nederlands.description".localized : "language.english.description".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Selection indicator
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.brewTheme)
                            .font(.title3)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(.secondary)
                            .font(.title3)
                    }
                }
                .padding()
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.brewTheme.opacity(0.1) : Color.primaryCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.brewTheme : Color.clear, lineWidth: 2)
                )
        )
        .padding(.horizontal)
    }
}

#Preview {
    LanguageSettingsView()
} 