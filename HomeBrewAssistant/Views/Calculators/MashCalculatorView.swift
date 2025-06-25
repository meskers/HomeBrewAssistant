import SwiftUI

struct MashCalculatorView: View {
    @State private var grainWeight: String = "5.0"
    @State private var mashThickness: String = "3.0"
    @State private var grainTemp: String = "20"
    @State private var targetMashTemp: String = "66"
    @State private var stepMashes: [MashStep] = []
    @State private var showingResults = false
    @State private var calculationResults: MashCalculation?
    @Environment(\.presentationMode) var presentationMode
    
    struct MashStep: Identifiable {
        let id = UUID()
        var temperature: String = "66"
        var duration: String = "60"
        var stepName: String = "Saccharification Rest"
    }
    
    struct MashCalculation {
        let strikeWaterVolume: Double
        let strikeWaterTemp: Double
        let totalMashVolume: Double
        let grainAbsorption: Double
        let spargeWaterVolume: Double
        let efficiency: Double
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "thermometer.medium")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                            .accessibilityHidden(true)
                        
                        Text("Mash Calculator")
                            .font(.largeTitle)
                            .font(.body.weight(.bold))
                            .accessibilityLabel("Mash Calculator")
                        
                        Text("Calculate strike water and step mash profiles")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Basic Parameters
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Mash Parameters")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Grain Weight:")
                                    .font(.subheadline)
                                    .frame(width: 120, alignment: .leading)
                                TextField("5.0", text: $grainWeight)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                Text("kg")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Text("Mash Thickness:")
                                    .font(.subheadline)
                                    .frame(width: 120, alignment: .leading)
                                TextField("3.0", text: $mashThickness)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                Text("L/kg")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Text("Grain Temp:")
                                    .font(.subheadline)
                                    .frame(width: 120, alignment: .leading)
                                TextField("20", text: $grainTemp)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                Text("°C")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Text("Target Temp:")
                                    .font(.subheadline)
                                    .frame(width: 120, alignment: .leading)
                                TextField("66", text: $targetMashTemp)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                Text("°C")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Step Mash Profile
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Step Mash Profile")
                                .font(.headline)
                            Spacer()
                            Button("Add Step") {
                                stepMashes.append(MashStep())
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                        
                        if stepMashes.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "plus.circle.dashed")
                                    .font(.title)
                                    .foregroundColor(.secondary)
                                Text("No mash steps defined")
                                    .foregroundColor(.secondary)
                                Text("Add steps for complex mash schedules")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(stepMashes.enumerated()), id: \.element.id) { index, step in
                                    MashStepRow(
                                        step: binding(for: index),
                                        stepNumber: index + 1,
                                        onDelete: { removeStep(at: index) }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calculate Button
                    Button(action: calculateMash) {
                        HStack {
                            Image(systemName: "flask.fill")
                            Text("Calculate Mash")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .font(.headline)
                    }
                    .padding(.horizontal)
                    
                    // Results
                    if showingResults, let results = calculationResults {
                        MashResultsView(results: results)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 100)
            }
            .navigationTitle("Mash Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func binding(for index: Int) -> Binding<MashStep> {
        Binding(
            get: { stepMashes[index] },
            set: { stepMashes[index] = $0 }
        )
    }
    
    private func removeStep(at index: Int) {
        stepMashes.remove(at: index)
    }
    
    private func calculateMash() {
        guard let grain = Double(grainWeight),
              let thickness = Double(mashThickness),
              let grainTemperature = Double(grainTemp),
              let targetTemp = Double(targetMashTemp) else {
            return
        }
        
        // Strike water calculations
        let strikeVolume = grain * thickness
        let strikeTemp = calculateStrikeWaterTemp(
            grainWeight: grain,
            grainTemp: grainTemperature,
            targetTemp: targetTemp,
            waterVolume: strikeVolume
        )
        
        // Mash calculations
        let totalVolume = strikeVolume + grain * 0.7 // Grain displacement
        let absorption = grain * 1.0 // L absorbed per kg grain
        let spargeVolume = calculateSpargeVolume(grainWeight: grain)
        let efficiency = calculateEfficiency(grainWeight: grain, mashThickness: thickness)
        
        calculationResults = MashCalculation(
            strikeWaterVolume: strikeVolume,
            strikeWaterTemp: strikeTemp,
            totalMashVolume: totalVolume,
            grainAbsorption: absorption,
            spargeWaterVolume: spargeVolume,
            efficiency: efficiency
        )
        
        showingResults = true
    }
    
    private func calculateStrikeWaterTemp(grainWeight: Double, grainTemp: Double, targetTemp: Double, waterVolume: Double) -> Double {
        // Palmer's formula for strike water temperature
        let r = waterVolume / grainWeight // Water to grain ratio
        return ((0.2 / r) * (targetTemp - grainTemp)) + targetTemp
    }
    
    private func calculateSpargeVolume(grainWeight: Double) -> Double {
        // Typical sparge volume calculation
        return grainWeight * 2.5 // L per kg grain
    }
    
    private func calculateEfficiency(grainWeight: Double, mashThickness: Double) -> Double {
        // Efficiency estimation based on mash thickness
        let baseEfficiency = 75.0
        let thicknessAdjustment = (mashThickness - 2.5) * 2.0
        return min(85.0, max(65.0, baseEfficiency + thicknessAdjustment))
    }
}

struct MashStepRow: View {
    @Binding var step: MashCalculatorView.MashStep
    let stepNumber: Int
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Step \(stepNumber)")
                    .font(.subheadline)
                    .font(.body.weight(.semibold))
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            TextField("Step name", text: $step.stepName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Temperature")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        TextField("66", text: $step.temperature)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                        Text("°C")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        TextField("60", text: $step.duration)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                        Text("min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct MashResultsView: View {
    let results: MashCalculatorView.MashCalculation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mash Calculations")
                .font(.headline)
            
            VStack(spacing: 12) {
                ResultRow(
                    title: "Strike Water Volume",
                    value: String(format: "%.1f L", results.strikeWaterVolume),
                    icon: "drop.circle.fill",
                    color: .blue
                )
                
                ResultRow(
                    title: "Strike Water Temperature",
                    value: String(format: "%.1f°C", results.strikeWaterTemp),
                    icon: "thermometer.medium",
                    color: .orange
                )
                
                ResultRow(
                    title: "Total Mash Volume",
                    value: String(format: "%.1f L", results.totalMashVolume),
                    icon: "cylinder.fill",
                    color: .green
                )
                
                ResultRow(
                    title: "Grain Absorption",
                    value: String(format: "%.1f L", results.grainAbsorption),
                    icon: "arrow.down.circle.fill",
                    color: .purple
                )
                
                ResultRow(
                    title: "Sparge Water Volume",
                    value: String(format: "%.1f L", results.spargeWaterVolume),
                    icon: "shower.fill",
                    color: .cyan
                )
                
                ResultRow(
                    title: "Expected Efficiency",
                    value: String(format: "%.1f%%", results.efficiency),
                    icon: "chart.line.uptrend.xyaxis.circle.fill",
                    color: .yellow
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ResultRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .font(.body.weight(.semibold))
        }
    }
}

#Preview {
    MashCalculatorView()
} 