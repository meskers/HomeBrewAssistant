import SwiftUI

struct VersionHistoryView: View {
    @StateObject private var versionManager = VersionManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with current version
                    currentVersionHeader
                    
                    // Version history
                    LazyVStack(spacing: 20) {
                        ForEach(versionManager.versionHistory) { version in
                            VersionCard(version: version)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("version.history.title".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("action.done".localized) {
                        dismiss()
                    }
                    .foregroundColor(.brewTheme)
                }
            }
        }
    }
    
    // MARK: - Current Version Header
    
    private var currentVersionHeader: some View {
        VStack(spacing: 15) {
            // App icon and name
            HStack(spacing: 15) {
                Image(systemName: "flask.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.brewTheme)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(Bundle.main.appName)
                        .font(.title2)
                        .font(.body.weight(.bold))
                    
                    Text("version.current".localized(with: versionManager.fullVersionString))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Version info cards
            HStack(spacing: 15) {
                VersionInfoCard(
                    title: "version.number".localized,
                    value: versionManager.currentVersion,
                    icon: "number.circle.fill",
                    color: .blue
                )
                
                VersionInfoCard(
                    title: "version.build".localized,
                    value: versionManager.currentBuildNumber,
                    icon: "hammer.circle.fill",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .padding(.horizontal)
        .padding(.top)
    }
}

// MARK: - Version Card

struct VersionCard: View {
    let version: VersionEntry
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    // Version type icon
                    Image(systemName: version.type.icon)
                        .font(.title2)
                        .foregroundColor(version.type.color)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("v\(version.version)")
                                .font(.headline)
                                .font(.body.weight(.bold))
                            
                            Text("(\(version.buildNumber))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text(version.type.description)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(version.type.color.opacity(0.2))
                                .foregroundColor(version.type.color)
                                .cornerRadius(8)
                            
                            Text(version.formattedDate)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expandable content
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Divider()
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("version.changes".localized)
                            .font(.subheadline)
                            .font(.body.weight(.semibold))
                            .padding(.horizontal)
                        
                        ForEach(version.changes, id: \.self) { change in
                            HStack(alignment: .top, spacing: 10) {
                                Text("•")
                                    .foregroundColor(.brewTheme)
                                    .font(.body.weight(.bold))
                                
                                Text(change)
                                    .font(.caption)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.primaryCard)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Version Info Card

struct VersionInfoCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .font(.body.weight(.bold))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.primaryCard)
        .cornerRadius(10)
    }
}

// MARK: - Preview

#Preview {
    VersionHistoryView()
        .environmentObject(LocalizationManager.shared)
} 