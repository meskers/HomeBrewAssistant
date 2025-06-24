import SwiftUI

struct SRMCalculatorView: View {
    @State private var batchSize: String = "20.0"
    @State private var grainBill: [GrainAddition] = []
    @State private var showingAddGrain = false
    @State private var calculatedSRM: Double = 0
    @Environment(\.presentationMode) var presentationMode
    
    struct GrainAddition: Identifiable {
        let id = UUID()
        var name: String
        var weight: Double // kg
        var color: Double // Lovibond
        
        func contribution(batchSize: Double) -> Double {
            let mcu = (weight * 2.2046) * color // Convert kg to lbs
            let mcuPerGallon = mcu / (batchSize * 0.264172) // Convert L to gallons
            return 1.4922 * pow(mcuPerGallon, 0.6859) // Morey equation
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.maltGold)
                        
                        Text("SRM Calculator")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Calculate beer color in SRM units")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Batch Size
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Batch Size")
                            .font(.headline)
                        
                        HStack {
                            TextField("20.0", text: $batchSize)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Text("L")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Grain Bill
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Grain Bill")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button("Add Grain") {
                                showingAddGrain = true
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.maltGold)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        
                        if grainBill.isEmpty {
                            Text("No grains added yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        } else {
                            ForEach(grainBill) { grain in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(grain.name)
                                            .font(.headline)
                                        Text("\(grain.weight, specifier: "%.2f") kg • \(grain.color, specifier: "%.1f")°L")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text("\(grain.contribution(batchSize: Double(batchSize) ?? 20.0), specifier: "%.1f")")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.maltGold)
                                        Text("SRM")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(radius: 1)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calculate Button & Results
                    VStack(spacing: 16) {
                        Button("Calculate SRM") {
                            calculateSRM()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(grainBill.isEmpty ? Color.gray : Color.maltGold)
                        .cornerRadius(12)
                        .disabled(grainBill.isEmpty)
                        .padding(.horizontal)
                        
                        if calculatedSRM > 0 {
                            VStack(spacing: 8) {
                                Text("Total SRM: \(calculatedSRM, specifier: "%.1f")")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.maltGold)
                                
                                Text(beerStyleForSRM(calculatedSRM))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("SRM Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showingAddGrain) {
                AddGrainView { grain in
                    grainBill.append(grain)
                    calculateSRM()
                }
            }
        }
    }
    
    private func calculateSRM() {
        let batchSizeDouble = Double(batchSize) ?? 20.0
        calculatedSRM = grainBill.reduce(0) { total, grain in
            total + grain.contribution(batchSize: batchSizeDouble)
        }
    }
    
    private func beerStyleForSRM(_ srm: Double) -> String {
        switch srm {
        case 0..<2: return "Light Lager (Pilsner)"
        case 2..<4: return "Pale (Pale Ale, Wheat)"
        case 4..<6: return "Golden (Blonde Ale)"
        case 6..<9: return "Amber (Amber Ale)"
        case 9..<12: return "Light Brown (English Bitter)"
        case 12..<18: return "Brown (Brown Ale)"
        case 18..<25: return "Dark Brown (Porter)"
        case 25..<35: return "Black (Stout)"
        default: return "Very Dark (Imperial Stout)"
        }
    }
}

struct AddGrainView: View {
    @State private var grainName: String = ""
    @State private var weight: String = ""
    @State private var color: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    let onAdd: (SRMCalculatorView.GrainAddition) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Grain Details") {
                    TextField("Grain name", text: $grainName)
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                    TextField("Color (°Lovibond)", text: $color)
                        .keyboardType(.decimalPad)
                }
                
                Section("Quick Select") {
                    Button("Pilsner Malt (1.8°L)") {
                        grainName = "Pilsner Malt"
                        color = "1.8"
                    }
                    Button("Pale Ale Malt (3.5°L)") {
                        grainName = "Pale Ale Malt"
                        color = "3.5"
                    }
                    Button("Crystal 60L") {
                        grainName = "Crystal 60L"
                        color = "60.0"
                    }
                    Button("Chocolate Malt (350°L)") {
                        grainName = "Chocolate Malt"
                        color = "350.0"
                    }
                }
            }
            .navigationTitle("Add Grain")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Add") {
                    addGrain()
                }.disabled(!isValidInput)
            )
        }
    }
    
    private var isValidInput: Bool {
        !grainName.isEmpty &&
        !weight.isEmpty && Double(weight) != nil &&
        !color.isEmpty && Double(color) != nil
    }
    
    private func addGrain() {
        guard isValidInput,
              let wt = Double(weight),
              let clr = Double(color) else { return }
        
        let grain = SRMCalculatorView.GrainAddition(
            name: grainName,
            weight: wt,
            color: clr
        )
        
        onAdd(grain)
        presentationMode.wrappedValue.dismiss()
    }
}

struct SRMCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        SRMCalculatorView()
    }
} 