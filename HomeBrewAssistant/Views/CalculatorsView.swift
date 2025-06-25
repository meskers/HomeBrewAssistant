import SwiftUI

struct CalculatorsView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedCalculator: CalculatorType? = nil
    
    enum CalculatorType: String, CaseIterable {
        case abv = "ABV"
        case ibu = "IBU" 
        case srm = "SRM"
        case carbonation = "CO₂"
        case water = "Water"
        case waterChemistry = "Water Chemistry"
        case mash = "Mash"
        case hydrometer = "Hydrometer"
        case strikeWater = "Strike Water"
        case yeastPitch = "Yeast Pitch"
        case brewTimer = "Brew Timer"
        
        var title: String {
            switch self {
            case .abv: return "calculator.abv.title".localized
            case .ibu: return "calculator.ibu.title".localized
            case .srm: return "calculator.srm.title".localized
            case .carbonation: return "calculator.co2.title".localized
            case .water: return "calculator.water.title".localized
            case .waterChemistry: return "Water Chemistry"
            case .mash: return "Mash Calculator"
            case .hydrometer: return "Hydrometer Correctie"
            case .strikeWater: return "Strike Water"
            case .yeastPitch: return "Gist Pitch Rate"
            case .brewTimer: return "Brouw Timer"
            }
        }
        
        var icon: String {
            switch self {
            case .abv: return "percent"
            case .ibu: return "drop.fill"
            case .srm: return "paintpalette.fill"
            case .carbonation: return "bubbles.and.sparkles"
            case .water: return "drop.triangle"
            case .waterChemistry: return "flask.fill"
            case .mash: return "thermometer.medium"
            case .hydrometer: return "thermometer"
            case .strikeWater: return "flame"
            case .yeastPitch: return "microbe"
            case .brewTimer: return "timer"
            }
        }
        
        var description: String {
            switch self {
            case .abv: return "calculator.abv.description".localized
            case .ibu: return "calculator.ibu.description".localized
            case .srm: return "calculator.srm.description".localized
            case .carbonation: return "calculator.co2.description".localized
            case .water: return "calculator.water.description".localized
            case .waterChemistry: return "Optimize brewing water mineral profile"
            case .mash: return "Calculate strike water temperature and mash schedules"
            case .hydrometer: return "Corrigeer gravity voor temperatuur"
            case .strikeWater: return "Bereken water temperatuur voor mashing"
            case .yeastPitch: return "Bereken hoeveel gist nodig is"
            case .brewTimer: return "Multi-timer voor brouwprocessen"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "function")
                                .font(.title2)
                                .foregroundColor(.brewTheme)
                                .accessibilityLabel("Calculator icon")
                            
                            VStack(alignment: .leading) {
                                Text("calculators.title".localized)
                                    .font(.title2)
                                    .font(.body.weight(.bold))
                                Text("calculators.subtitle".localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .accessibilityElement(children: .combine)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                        ForEach(CalculatorType.allCases, id: \.rawValue) { calculator in
                            CalculatorCard(calculator: calculator)
                                .premiumCard()
                                .premiumButton(hapticStyle: .medium)
                                .onTapGesture {
                                    HapticManager.shared.mediumTap()
                                    withAnimation(.premiumSlide) {
                                        selectedCalculator = calculator
                                    }
                                }
                                .accessibilityLabel("Open \(calculator.title) calculator")
                                .accessibilityHint(calculator.description)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("calculators.title".localized)
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(item: $selectedCalculator) { calculator in
            calculatorView(for: calculator)
        }
        .accessibilityElement(children: .contain)
    }
    
    @ViewBuilder
    private func calculatorView(for calculator: CalculatorType) -> some View {
        switch calculator {
        case .abv:
            ABVCalculatorView()
        case .ibu:
            IBUCalculatorView()
        case .srm:
            SRMCalculatorView()
        case .carbonation:
            CarbonationCalculatorView()
        case .water:
            ComingSoonView(title: "Water Calculator", description: "Water treatment calculator coming soon!")
        case .waterChemistry:
            WaterChemistryCalculatorView()
        case .mash:
            MashCalculatorView()
        case .hydrometer:
            HydrometerCalculatorView()
        case .strikeWater:
            StrikeWaterCalculatorView()
        case .yeastPitch:
            ComingSoonView(title: "Yeast Pitch Rate", description: "Yeast pitch rate calculator - temporarily unavailable during refactoring")
        case .brewTimer:
            ComingSoonView(title: "Brew Timer", description: "Multi-timer for brewing processes - temporarily unavailable during refactoring")
        }
    }
}

// MARK: - Calculator Card Component
struct CalculatorCard: View {
    let calculator: CalculatorsView.CalculatorType
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: calculator.icon)
                .font(.system(size: 30))
                .foregroundColor(.brewTheme)
            
            // Title
            Text(calculator.title)
                .font(.headline)
                .font(.body.weight(.semibold))
                .multilineTextAlignment(.center)
            
            // Description
            Text(calculator.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .padding()
        .background(Color.primaryCard)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Coming Soon Placeholder
struct ComingSoonView: View {
    let title: String
    let description: String
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "wrench.and.screwdriver")
                    .font(.system(size: 60))
                    .foregroundColor(.brewTheme)
                
                Text(title)
                    .font(.title2)
                    .font(.body.weight(.bold))
                
                Text(description)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                Text("🚧 Under Construction 🚧")
                    .font(.headline)
                    .foregroundColor(.orange)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        // Dismiss handled by sheet
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

extension CalculatorsView.CalculatorType: Identifiable {
    var id: String { rawValue }
}

#Preview {
    CalculatorsView()
}
