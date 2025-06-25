import SwiftUI

struct MoreView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Binding var selectedRecipeForBrewing: DetailedRecipe?
    @Binding var recipes: [DetailedRecipe]
    @State private var selectedFeature: MoreFeature? = nil
    @State private var showingLanguageSettings = false
    @State private var showingAbout = false
    
    enum MoreFeature: String, CaseIterable {
        case analytics = "analytics"
        case photos = "photos"
        case history = "history"
        case beerxml = "beerxml"
        
        var title: String {
            switch self {
            case .analytics: return "more.analytics.title".localized
            case .photos: return "more.photos.title".localized
            case .history: return "more.history.title".localized
            case .beerxml: return "more.beerxml.title".localized
            }
        }
        
        var icon: String {
            switch self {
            case .analytics: return "chart.bar.fill"
            case .photos: return "photo.stack.fill"
            case .history: return "clock.arrow.circlepath"
            case .beerxml: return "doc.text.fill"
            }
        }
        
        var description: String {
            switch self {
            case .analytics: return "more.analytics.description".localized
            case .photos: return "more.photos.description".localized
            case .history: return "more.history.description".localized
            case .beerxml: return "more.beerxml.description".localized
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title2)
                            .foregroundColor(.brewTheme)
                            .accessibilityHidden(true)
                        
                        VStack(alignment: .leading) {
                            Text("more.title".localized)
                                .font(.title2)
                                .font(.body.weight(.bold))
                            Text("more.subtitle".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("more.title".localized + ", " + "more.subtitle".localized)
                
                List {
                    // Features Section
                    Section("more.features.section".localized) {
                        ForEach(MoreFeature.allCases, id: \.rawValue) { feature in
                            MoreFeatureRow(feature: feature)
                                .onTapGesture {
                                    selectedFeature = feature
                                }
                        }
                    }
                    
                    // Settings Section
                    Section("more.settings.section".localized) {
                        SettingsRow(
                            title: "more.language.title".localized,
                            icon: "globe",
                            subtitle: localizationManager.currentLanguage.displayName
                        )
                        .onTapGesture {
                            showingLanguageSettings = true
                        }
                        
                        SettingsRow(
                            title: "more.about.title".localized,
                            icon: "info.circle",
                            subtitle: "more.about.subtitle".localized
                        )
                        .onTapGesture {
                            showingAbout = true
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("more.title".localized)
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(item: $selectedFeature) { feature in
            featureView(for: feature)
        }
        .sheet(isPresented: $showingLanguageSettings) {
            LanguageSettingsView()
                .environmentObject(localizationManager)
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
                .environmentObject(localizationManager)
        }
    }
    
    @ViewBuilder
    private func featureView(for feature: MoreFeature) -> some View {
        switch feature {
        case .analytics:
            BrewAnalyticsView()
                .environmentObject(localizationManager)
        case .photos:
            Text("Foto functie tijdelijk uitgeschakeld")
                .font(.title2)
                .foregroundColor(.secondary)
                .padding()
        case .history:
            BrewHistoryView()
                .environmentObject(localizationManager)
        case .beerxml:
            BeerXMLImportExportView(recipes: $recipes)
                .environmentObject(localizationManager)
        }
    }
}

struct MoreFeatureRow: View {
    let feature: MoreView.MoreFeature
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            Image(systemName: feature.icon)
                .font(.title2)
                .foregroundColor(.brewTheme)
                .frame(width: 30)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(.headline)
                    .font(.body.weight(.medium))
                
                Text(feature.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(feature.title)")
        .accessibilityHint("\(feature.description). Tik om te openen.")
        .accessibilityAddTraits(.isButton)
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.brewTheme)
                .frame(width: 30)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .font(.body.weight(.medium))
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(subtitle)")
        .accessibilityHint("Tik om \(title.lowercased()) te openen")
        .accessibilityAddTraits(.isButton)
    }
}

extension MoreView.MoreFeature: Identifiable {
    var id: String { rawValue }
}

#Preview {
    MoreView(selectedRecipeForBrewing: .constant(nil), recipes: .constant([]))
} 