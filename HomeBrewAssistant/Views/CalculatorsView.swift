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
        
        var title: String {
            switch self {
            case .abv: return "calculator.abv.title".localized
            case .ibu: return "calculator.ibu.title".localized
            case .srm: return "calculator.srm.title".localized
            case .carbonation: return "calculator.co2.title".localized
            case .water: return "calculator.water.title".localized
            }
        }
        
        var icon: String {
            switch self {
            case .abv: return "percent"
            case .ibu: return "drop.fill"
            case .srm: return "paintpalette.fill"
            case .carbonation: return "bubbles.and.sparkles"
            case .water: return "drop.triangle"
            }
        }
        
        var description: String {
            switch self {
            case .abv: return "calculator.abv.description".localized
            case .ibu: return "calculator.ibu.description".localized
            case .srm: return "calculator.srm.description".localized
            case .carbonation: return "calculator.co2.description".localized
            case .water: return "calculator.water.description".localized
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "function")
                            .font(.title2)
                            .foregroundColor(.brewTheme)
                        
                        VStack(alignment: .leading) {
                            Text("calculators.title".localized)
                                .font(.title2)
                                .fontWeight(.bold)
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
                .padding(.horizontal)
                .padding(.top)
                
                // Calculator grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                    ForEach(CalculatorType.allCases, id: \.rawValue) { calculator in
                        CalculatorCard(calculator: calculator)
                            .onTapGesture {
                                selectedCalculator = calculator
                            }
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("calculators.title".localized)
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(item: $selectedCalculator) { calculator in
            calculatorView(for: calculator)
        }
    }
    
    @ViewBuilder
    private func calculatorView(for calculator: CalculatorType) -> some View {
        switch calculator {
        case .abv:
            SimpleABVCalculatorView()
        case .ibu:
            IBUCalculatorView()
        case .srm:
            SRMCalculatorView()
        case .carbonation:
            CarbonationCalculatorView()
        case .water:
            WaterCalculatorView()
        }
    }
}

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
                .fontWeight(.semibold)
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
    }
}

extension CalculatorsView.CalculatorType: Identifiable {
    var id: String { rawValue }
}

#Preview {
    CalculatorsView()
} 