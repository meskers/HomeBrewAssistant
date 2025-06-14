import SwiftUI

struct PlaceholderBrewMonitorView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "flask.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.brewTheme)
                
                Text("🧪 Brew Monitor")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Advanced Brewing Process Monitoring")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    Text("Coming in v1.3:")
                        .font(.headline)
                        .foregroundColor(.brewTheme)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("🌡️ Temperature Tracking", systemImage: "thermometer")
                        Label("⏱️ Advanced Timer System", systemImage: "timer")
                        Label("📋 Step-by-Step Guidance", systemImage: "list.clipboard")
                        Label("📊 Process Analytics", systemImage: "chart.line.uptrend.xyaxis")
                        Label("📝 Brew Session Notes", systemImage: "note.text")
                    }
                    .font(.subheadline)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
                
                Text("Stay tuned for advanced brewing tools!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("Brew Monitor")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    PlaceholderBrewMonitorView()
} 