import SwiftUI

struct SettingsView: View {
    @AppStorage("useMetricSystem") private var useMetricSystem = true
    @AppStorage("darkMode") private var darkMode = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("defaultBatchSize") private var defaultBatchSize = 20.0
    @AppStorage("defaultEfficiency") private var defaultEfficiency = 75.0
    
    @State private var showingDisclaimer = false
    @State private var showingAbout = false
    @State private var showingFactoryReset = false
    @State private var showingResetProgress = false
    @State private var showingResetComplete = false
    
    @StateObject private var factoryResetManager = FactoryResetManager.shared
    
    var body: some View {
        NavigationView {
            Form {
                // Units Section
                Section(header: Text("settings.units".localized)) {
                    Toggle("settings.use.metric".localized, isOn: $useMetricSystem)
                }
                
                // Appearance Section
                Section(header: Text("settings.appearance".localized)) {
                    Toggle("settings.dark.mode".localized, isOn: $darkMode)
                }
                
                // Notifications Section
                Section(header: Text("settings.notifications".localized)) {
                    Toggle("settings.enable.notifications".localized, isOn: $notificationsEnabled)
                }
                
                // Default Values Section
                Section(header: Text("settings.default.values".localized)) {
                    HStack {
                        Text("settings.default.batch.size".localized)
                        Spacer()
                        TextField("unit.liters".localized, value: $defaultBatchSize, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("settings.default.efficiency".localized)
                        Spacer()
                        TextField("unit.percent".localized, value: $defaultEfficiency, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
                
                // Factory Reset Section - for App Store ready clean state
                Section(
                    header: Text("🧹 " + "factory.reset.section".localized),
                    footer: Text("factory.reset.description".localized)
                        .foregroundColor(.secondary)
                ) {
                    Button {
                        showingFactoryReset = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("factory.reset.title".localized)
                                    .foregroundColor(.primary)
                                    .fontWeight(.medium)
                                Text("factory.reset.subtitle".localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if factoryResetManager.isResetting {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .disabled(factoryResetManager.isResetting)
                }
                
                // App Information Section
                Section {
                    Button("settings.disclaimer".localized) {
                        showingDisclaimer = true
                    }
                    .foregroundColor(.primary)
                    
                    Button("settings.about".localized) {
                        showingAbout = true
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("settings.title".localized)
            .sheet(isPresented: $showingDisclaimer) {
                DisclaimerView()
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .alert("factory.reset.alert.title".localized, isPresented: $showingFactoryReset) {
                Button("factory.reset.cancel".localized, role: .cancel) { }
                Button("factory.reset.confirm".localized, role: .destructive) {
                    performFactoryReset()
                }
            } message: {
                Text("factory.reset.alert.message".localized)
            }
            .sheet(isPresented: $showingResetProgress) {
                FactoryResetProgressView()
                    .environmentObject(factoryResetManager)
            }
            .alert("factory.reset.complete.title".localized, isPresented: $showingResetComplete) {
                Button("factory.reset.perfect".localized) {
                    // App is now in perfect App Store state
                }
            } message: {
                Text("factory.reset.complete.message".localized)
            }
        }
    }
    
    private func performFactoryReset() {
        showingResetProgress = true
        
        Task {
            do {
                try await factoryResetManager.performFactoryReset()
                await MainActor.run {
                    showingResetProgress = false
                    showingResetComplete = true
                }
            } catch {
                await MainActor.run {
                    showingResetProgress = false
                    print("❌ Factory reset failed: \(error)")
                }
            }
        }
    }
}

// MARK: - Factory Reset Progress View
struct FactoryResetProgressView: View {
    @EnvironmentObject private var factoryResetManager: FactoryResetManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Progress Animation
                ZStack {
                    Circle()
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 8)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: factoryResetManager.resetProgress)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: factoryResetManager.resetProgress)
                    
                    Image(systemName: "sparkles")
                        .font(.title)
                        .foregroundColor(.orange)
                        .scaleEffect(1 + factoryResetManager.resetProgress * 0.5)
                        .animation(.easeInOut(duration: 0.5), value: factoryResetManager.resetProgress)
                }
                
                VStack(spacing: 12) {
                    Text("factory.reset.progress.title".localized)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("\(Int(factoryResetManager.resetProgress * 100))" + "factory.reset.progress.complete".localized)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("factory.reset.progress.subtitle".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    if factoryResetManager.resetProgress > 0.8 {
                        Text("factory.reset.progress.almost".localized)
                            .font(.caption)
                            .foregroundColor(.orange)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("factory.reset.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !factoryResetManager.isResetting {
                        Button("action.done".localized) {
                            dismiss()
                        }
                    }
                }
            }
        }
        .interactiveDismissDisabled(factoryResetManager.isResetting)
    }
}

#Preview {
    SettingsView()
}
