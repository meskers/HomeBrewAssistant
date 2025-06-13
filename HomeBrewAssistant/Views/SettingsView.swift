import SwiftUI

struct SettingsView: View {
    @AppStorage("useMetricSystem") private var useMetricSystem = true
    @AppStorage("darkMode") private var darkMode = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("defaultBatchSize") private var defaultBatchSize = 20.0
    @AppStorage("defaultEfficiency") private var defaultEfficiency = 75.0
    
    @State private var showingDisclaimer = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Units")) {
                    Toggle("Use Metric System", isOn: $useMetricSystem)
                }
                
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $darkMode)
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                }
                
                Section(header: Text("Default Values")) {
                    HStack {
                        Text("Default Batch Size")
                        Spacer()
                        TextField("Liters", value: $defaultBatchSize, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Default Efficiency")
                        Spacer()
                        TextField("%", value: $defaultEfficiency, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
                
                Section {
                    Button("Disclaimer") {
                        showingDisclaimer = true
                    }
                    
                    Button("About") {
                        showingAbout = true
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingDisclaimer) {
                DisclaimerView()
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
}

#Preview {
    SettingsView()
} 