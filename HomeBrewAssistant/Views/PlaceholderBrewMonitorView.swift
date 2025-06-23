import SwiftUI

struct PlaceholderBrewMonitorView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "flask.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.brewTheme)
                
                Text("brew.monitor.title".localized)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("brew.monitor.subtitle".localized)
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    Text("brew.monitor.coming.soon".localized)
                        .font(.headline)
                        .foregroundColor(.brewTheme)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("brew.monitor.feature.temperature".localized, systemImage: "thermometer")
                        Label("brew.monitor.feature.timers".localized, systemImage: "timer")
                        Label("brew.monitor.feature.guidance".localized, systemImage: "list.clipboard")
                        Label("brew.monitor.feature.analytics".localized, systemImage: "chart.line.uptrend.xyaxis")
                        Label("brew.monitor.feature.notes".localized, systemImage: "note.text")
                    }
                    .font(.subheadline)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
                
                Text("brew.monitor.stay.tuned".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("brew.monitor.nav.title".localized)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    PlaceholderBrewMonitorView()
} 