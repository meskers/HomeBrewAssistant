import SwiftUI

struct WaterChemistryCalculatorView: View {
    @State private var calciumLevel: String = ""
    @State private var magnesiumLevel: String = ""
    @State private var sodiumLevel: String = ""
    @State private var sulfateLevel: String = ""
    @State private var chlorideLevel: String = ""
    @State private var bicarbonateLevel: String = ""
    @State private var selectedBeerStyle: BeerStyle = .ipa
    @State private var showingResults = false
    @State private var waterProfile: WaterProfile?
    @Environment(\.presentationMode) var presentationMode
    
    enum BeerStyle: String, CaseIterable {
        case ipa = "IPA"
        case pilsner = "Pilsner"
        case stout = "Stout"
        case lager = "Lager"
        case wheat = "Wheat Beer"
        case sour = "Sour Beer"
        
        var targetProfile: WaterProfile {
            switch self {
            case .ipa:
                return WaterProfile(
                    calcium: 150...300,
                    magnesium: 10...30,
                    sodium: 0...150,
                    sulfate: 200...400,
                    chloride: 50...150,
                    bicarbonate: 0...50,
                    description: "IPA - High sulfate for hoppy character"
                )
            case .pilsner:
                return WaterProfile(
                    calcium: 7...35,
                    magnesium: 2...10,
                    sodium: 0...10,
                    sulfate: 5...15,
                    chloride: 3...10,
                    bicarbonate: 15...35,
                    description: "Pilsner - Soft water profile"
                )
            case .stout:
                return WaterProfile(
                    calcium: 100...200,
                    magnesium: 10...30,
                    sodium: 10...50,
                    sulfate: 50...150,
                    chloride: 50...150,
                    bicarbonate: 100...300,
                    description: "Stout - Balanced, higher alkalinity"
                )
            case .lager:
                return WaterProfile(
                    calcium: 50...150,
                    magnesium: 10...30,
                    sodium: 0...25,
                    sulfate: 25...75,
                    chloride: 25...75,
                    bicarbonate: 25...75,
                    description: "Lager - Clean, balanced profile"
                )
            case .wheat:
                return WaterProfile(
                    calcium: 50...150,
                    magnesium: 10...30,
                    sodium: 0...50,
                    sulfate: 10...50,
                    chloride: 50...150,
                    bicarbonate: 50...150,
                    description: "Wheat - Soft, chloride-forward"
                )
            case .sour:
                return WaterProfile(
                    calcium: 50...150,
                    magnesium: 5...25,
                    sodium: 0...25,
                    sulfate: 5...50,
                    chloride: 10...75,
                    bicarbonate: 0...25,
                    description: "Sour - Low alkalinity for acidity"
                )
            }
        }
    }
    
    struct WaterProfile {
        let calcium: ClosedRange<Double>
        let magnesium: ClosedRange<Double>
        let sodium: ClosedRange<Double>
        let sulfate: ClosedRange<Double>
        let chloride: ClosedRange<Double>
        let bicarbonate: ClosedRange<Double>
        let description: String
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "drop.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)
                        
                        Text("Water Chemistry")
                            .font(.largeTitle)
                            .font(.body.weight(.bold))
                            .accessibilityLabel("Water Chemistry Calculator")
                        
                        Text("Optimize your water profile for perfect beer")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .accessibilityLabel("Optimize your water profile for perfect beer")
                    }
                    .padding(.top)
                    
                    // Beer Style Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Beer Style")
                            .font(.headline)
                            .accessibilityLabel("Select beer style")
                        
                        Picker("Beer Style", selection: $selectedBeerStyle) {
                            ForEach(BeerStyle.allCases, id: \.self) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .accessibilityLabel("Beer style picker")
                        .accessibilityHint("Choose the style of beer you're brewing")
                    }
                    .padding(.horizontal)
                    
                    // Current Water Profile Input
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Current Water Profile")
                            .font(.headline)
                            .accessibilityLabel("Current water profile")
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            WaterParameterInput(
                                title: "Calcium (Ca²⁺)",
                                value: $calciumLevel,
                                unit: "ppm",
                                icon: "ca.circle",
                                color: .orange
                            )
                            
                            WaterParameterInput(
                                title: "Magnesium (Mg²⁺)",
                                value: $magnesiumLevel,
                                unit: "ppm",
                                icon: "mg.circle",
                                color: .green
                            )
                            
                            WaterParameterInput(
                                title: "Sodium (Na⁺)",
                                value: $sodiumLevel,
                                unit: "ppm",
                                icon: "na.circle",
                                color: .purple
                            )
                            
                            WaterParameterInput(
                                title: "Sulfate (SO₄²⁻)",
                                value: $sulfateLevel,
                                unit: "ppm",
                                icon: "s.circle",
                                color: .yellow
                            )
                            
                            WaterParameterInput(
                                title: "Chloride (Cl⁻)",
                                value: $chlorideLevel,
                                unit: "ppm",
                                icon: "cl.circle",
                                color: .blue
                            )
                            
                            WaterParameterInput(
                                title: "Bicarbonate (HCO₃⁻)",
                                value: $bicarbonateLevel,
                                unit: "ppm",
                                icon: "hco3.circle",
                                color: .red
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calculate Button
                    Button(action: calculateWaterProfile) {
                        HStack {
                            Image(systemName: "function")
                            Text("Analyze Water Profile")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .accessibilityLabel("Calculate water profile")
                    .accessibilityHint("Analyze your water and get recommendations")
                    
                    // Results Section
                    if showingResults {
                        WaterAnalysisResultsView(
                            currentProfile: getCurrentWaterValues(),
                            targetProfile: selectedBeerStyle.targetProfile,
                            beerStyle: selectedBeerStyle
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Water Chemistry")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .animation(.easeInOut(duration: 0.3), value: showingResults)
    }
    
    private func calculateWaterProfile() {
        withAnimation {
            showingResults = true
            // Haptic feedback for premium feel
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }
    
    private func getCurrentWaterValues() -> [String: Double] {
        return [
            "calcium": Double(calciumLevel) ?? 0,
            "magnesium": Double(magnesiumLevel) ?? 0,
            "sodium": Double(sodiumLevel) ?? 0,
            "sulfate": Double(sulfateLevel) ?? 0,
            "chloride": Double(chlorideLevel) ?? 0,
            "bicarbonate": Double(bicarbonateLevel) ?? 0
        ]
    }
}

struct WaterParameterInput: View {
    let title: String
    @Binding var value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .accessibilityHidden(true)
                Text(title)
                    .font(.caption)
                    .font(.body.weight(.medium))
                Spacer()
            }
            
            HStack {
                TextField("0", text: $value)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityLabel("\(title) input field")
                    .accessibilityHint("Enter the \(title.lowercased()) level in parts per million")
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .accessibilityHidden(true)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct WaterAnalysisResultsView: View {
    let currentProfile: [String: Double]
    let targetProfile: WaterChemistryCalculatorView.WaterProfile
    let beerStyle: WaterChemistryCalculatorView.BeerStyle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Analysis Results")
                .font(.headline)
                .accessibilityLabel("Water analysis results")
            
            Text(targetProfile.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ParameterAnalysisCard(
                    parameter: "Calcium",
                    current: currentProfile["calcium"] ?? 0,
                    target: targetProfile.calcium,
                    color: .orange
                )
                
                ParameterAnalysisCard(
                    parameter: "Magnesium",
                    current: currentProfile["magnesium"] ?? 0,
                    target: targetProfile.magnesium,
                    color: .green
                )
                
                ParameterAnalysisCard(
                    parameter: "Sodium",
                    current: currentProfile["sodium"] ?? 0,
                    target: targetProfile.sodium,
                    color: .purple
                )
                
                ParameterAnalysisCard(
                    parameter: "Sulfate",
                    current: currentProfile["sulfate"] ?? 0,
                    target: targetProfile.sulfate,
                    color: .yellow
                )
                
                ParameterAnalysisCard(
                    parameter: "Chloride",
                    current: currentProfile["chloride"] ?? 0,
                    target: targetProfile.chloride,
                    color: .blue
                )
                
                ParameterAnalysisCard(
                    parameter: "Bicarbonate",
                    current: currentProfile["bicarbonate"] ?? 0,
                    target: targetProfile.bicarbonate,
                    color: .red
                )
            }
            
            // Sulfate to Chloride Ratio Analysis
            SulfateChlorideRatioView(
                sulfate: currentProfile["sulfate"] ?? 0,
                chloride: currentProfile["chloride"] ?? 0,
                beerStyle: beerStyle
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.horizontal)
    }
}

struct ParameterAnalysisCard: View {
    let parameter: String
    let current: Double
    let target: ClosedRange<Double>
    let color: Color
    
    private var status: (String, Color, String) {
        if target.contains(current) {
            return ("✓", .green, "Optimal")
        } else if current < target.lowerBound {
            return ("↑", .orange, "Too Low")
        } else {
            return ("↓", .red, "Too High")
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(parameter)
                .font(.caption)
                .font(.body.weight(.medium))
                .accessibilityLabel(parameter)
            
            Text(status.0)
                .font(.title2)
                .font(.body.weight(.bold))
                .foregroundColor(status.1)
                .accessibilityHidden(true)
            
            Text("\(Int(current)) ppm")
                .font(.caption2)
                .foregroundColor(.secondary)
                .accessibilityLabel("\(Int(current)) parts per million")
            
            Text(status.2)
                .font(.caption2)
                .foregroundColor(status.1)
                .font(.body.weight(.medium))
                .accessibilityLabel(status.2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(parameter): \(Int(current)) ppm, \(status.2)")
    }
}

struct SulfateChlorideRatioView: View {
    let sulfate: Double
    let chloride: Double
    let beerStyle: WaterChemistryCalculatorView.BeerStyle
    
    private var ratio: Double {
        guard chloride > 0 else { return 0 }
        return sulfate / chloride
    }
    
    private var ratioAnalysis: (String, Color, String) {
        switch beerStyle {
        case .ipa:
            if ratio >= 2.0 {
                return ("Excellent", .green, "Perfect for hoppy beers")
            } else if ratio >= 1.0 {
                return ("Good", .orange, "Could be more hoppy")
            } else {
                return ("Malty", .red, "Too malty for IPA")
            }
        case .pilsner, .lager:
            if ratio >= 0.5 && ratio <= 1.5 {
                return ("Balanced", .green, "Perfect balance")
            } else {
                return ("Unbalanced", .orange, "Adjust for better balance")
            }
        case .stout, .wheat:
            if ratio <= 1.0 {
                return ("Malty", .green, "Good malty character")
            } else {
                return ("Too Hoppy", .orange, "Reduce sulfate")
            }
        case .sour:
            if ratio <= 0.8 {
                return ("Good", .green, "Suitable for sour profile")
            } else {
                return ("High", .orange, "Consider reducing sulfate")
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sulfate:Chloride Ratio")
                .font(.headline)
                .accessibilityLabel("Sulfate to chloride ratio analysis")
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Ratio: \(ratio, specifier: "%.1f"):1")
                        .font(.title2)
                        .font(.body.weight(.bold))
                        .accessibilityLabel("Ratio \(ratio, specifier: "%.1f") to 1")
                    
                    Text(ratioAnalysis.2)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityLabel(ratioAnalysis.2)
                }
                
                Spacer()
                
                Text(ratioAnalysis.0)
                    .font(.headline)
                    .font(.body.weight(.bold))
                    .foregroundColor(ratioAnalysis.1)
                    .accessibilityLabel(ratioAnalysis.0)
            }
            .padding()
            .background(ratioAnalysis.1.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

// Preview
struct WaterChemistryCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        WaterChemistryCalculatorView()
    }
} 