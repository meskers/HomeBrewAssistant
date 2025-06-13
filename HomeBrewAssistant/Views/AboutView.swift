import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @StateObject private var versionManager = VersionManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingLanguageSettings = false
    @State private var showingVersionHistory = false
    
    // App info - Deze kunnen later uit Bundle.main komen
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    private let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "HomeBrewAssistant"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // App Header
                    VStack(spacing: 15) {
                        Image(systemName: "flask.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.aboutBrewTheme)
                        
                        Text("HomeBrewAssistant")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Jouw persoonlijke brouwgids")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        // Quick Settings Section
                        VStack(spacing: 12) {
                            Button(action: { showingLanguageSettings = true }) {
                                HStack {
                                    Image(systemName: "globe")
                                        .foregroundColor(.aboutBrewTheme)
                                    Text("Taal wijzigen / Change Language")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(localizationManager.currentLanguage.flag)
                                        .font(.title3)
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    
                    // App Description
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Over de App")
                            .font(.headline)
                            .foregroundColor(.aboutBrewTheme)
                        
                        Text("HomeBrewAssistant is jouw ultieme companion voor het brouwen van bier thuis. Of je nu een beginnende brouwer bent of een ervaren hobbyist, deze app helpt je bij elke stap van het brouwproces.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Version Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Versie Informatie")
                            .font(.headline)
                            .foregroundColor(.aboutBrewTheme)
                        
                        Button(action: {
                            showingVersionHistory = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    InfoRow(label: "Versie", value: versionManager.currentVersion)
                                    InfoRow(label: "Build", value: versionManager.currentBuildNumber)
                                    InfoRow(label: "Platform", value: "iOS 18.4+")
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .font(.title2)
                                        .foregroundColor(.aboutBrewTheme)
                                    Text("Geschiedenis")
                                        .font(.caption)
                                        .foregroundColor(.aboutBrewTheme)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                    
                    // Developer Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ontwikkelaar")
                            .font(.headline)
                            .foregroundColor(.aboutBrewTheme)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.aboutBrewTheme)
                                Text("Cor Meskers")
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.aboutBrewTheme)
                                Text("cor@meskersonline.nl")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Features Grid
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Functies")
                            .font(.headline)
                            .foregroundColor(.aboutBrewTheme)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            FeatureCard(icon: "book.fill", title: "Recepten", description: "Beheer je brouwrecepten")
                            FeatureCard(icon: "list.clipboard.fill", title: "Ingrediënten", description: "Voorraad bijhouden")
                            FeatureCard(icon: "timer", title: "Brouw Tracker", description: "Volg je brouwsessies")
                            FeatureCard(icon: "percent", title: "ABV Calculator", description: "Bereken alcoholpercentage")
                            FeatureCard(icon: "drop.fill", title: "IBU Calculator", description: "Bereken bitterheid")
                            FeatureCard(icon: "paintpalette.fill", title: "SRM Calculator", description: "Voorspel kleur")
                            FeatureCard(icon: "bubbles.and.sparkles.fill", title: "CO₂ Calculator", description: "Carbonatie berekenen")
                            FeatureCard(icon: "drop.circle.fill", title: "Water Profiel", description: "Water samenstelling")
                            FeatureCard(icon: "camera.fill", title: "Foto Galerij", description: "Brouw documentatie")
                            FeatureCard(icon: "chart.bar.fill", title: "Analytics", description: "Brouw statistieken")
                            FeatureCard(icon: "arrow.up.and.down.and.arrow.left.and.right", title: "Recipe Scaling", description: "Recepten opschalen")
                            FeatureCard(icon: "globe", title: "Meertalig", description: "Nederlands & Engels")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Legal Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Juridisch")
                            .font(.headline)
                            .foregroundColor(.aboutBrewTheme)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("© 2024 Cor Meskers. Alle rechten voorbehouden.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("⚠️ Disclaimer: Deze app is alleen bedoeld voor educatieve doeleinden. Brouw altijd verantwoordelijk en volg lokale wetgeving betreffende het brouwen van alcoholische dranken.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("🔞 Alleen voor 18+. Drink met mate.")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Acknowledgments
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Dankbetuigingen")
                            .font(.headline)
                            .foregroundColor(.aboutBrewTheme)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("• Gemaakt met SwiftUI en Core Data")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("• Dank aan de homebrewing gemeenschap")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("• Gebaseerd op BJCP richtlijnen")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Over")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingLanguageSettings) {
            LanguageSettingsView()
                .environmentObject(localizationManager)
        }
        .sheet(isPresented: $showingVersionHistory) {
            VersionHistoryView()
                .environmentObject(localizationManager)
        }
        .onAppear {
            Task {
                await versionManager.checkForNewVersion()
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 2)
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.aboutBrewTheme)
            
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

extension Color {
    static let aboutBrewTheme = Color.orange
}

#Preview {
    AboutView()
        .environmentObject(LocalizationManager.shared)
} 