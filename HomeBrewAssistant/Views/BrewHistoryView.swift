import SwiftUI

struct BrewHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var brewSessions: [BrewSession] = []
    @State private var selectedTimeframe: BrewTimeframe = .all
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerView
                    
                    if brewSessions.isEmpty {
                        emptyStateView
                    } else {
                        brewHistoryContent
                    }
                }
                .padding()
            }
            .background(Color(.systemGray6))
            .navigationTitle("history.title".localized)
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
        .onAppear {
            loadBrewHistory()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 40))
                    .foregroundColor(.brewTheme)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("history.subtitle".localized)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("history.description".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Quick stats
            if !brewSessions.isEmpty {
                HStack(spacing: 20) {
                    StatCard(
                        title: "Total Brews",
                        value: "\(brewSessions.count)",
                        icon: "drop.circle.fill",
                        color: .brewTheme
                    )
                    
                    StatCard(
                        title: "Success Rate",
                        value: "\(successRate)%",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Active",
                        value: "\(activeBrowsCount)",
                        icon: "timer.circle.fill",
                        color: .orange
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "clock.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("history.empty.title".localized)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("history.empty.message".localized)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: {
                dismiss()
            }) {
                Text("history.start.first.brew".localized)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.brewTheme)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
        .padding(40)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Brew History Content
    private var brewHistoryContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Timeframe selector
            Picker("Timeframe", selection: $selectedTimeframe) {
                ForEach(BrewTimeframe.allCases, id: \.self) { timeframe in
                    Text(timeframe.displayName)
                        .tag(timeframe)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Brew sessions list
            LazyVStack(spacing: 12) {
                ForEach(filteredSessions) { session in
                    BrewSessionCard(session: session)
                }
            }
        }
    }
    
    // MARK: - Stat Card Component
    private func StatCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Computed Properties
    private var activeBrowsCount: Int {
        brewSessions.filter { $0.status != .completed && $0.status != .failed }.count
    }
    
    private var successRate: Int {
        guard !brewSessions.isEmpty else { return 0 }
        let successfulBrews = brewSessions.filter { $0.status == .completed }.count
        return Int((Double(successfulBrews) / Double(brewSessions.count)) * 100)
    }
    
    private var filteredSessions: [BrewSession] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeframe {
        case .all:
            return brewSessions
        case .thisWeek:
            return brewSessions.filter { session in
                calendar.isDate(session.brewDate, equalTo: now, toGranularity: .weekOfYear)
            }
        case .thisMonth:
            return brewSessions.filter { session in
                calendar.isDate(session.brewDate, equalTo: now, toGranularity: .month)
            }
        case .thisYear:
            return brewSessions.filter { session in
                calendar.isDate(session.brewDate, equalTo: now, toGranularity: .year)
            }
        }
    }
    
    // MARK: - Data Loading
    private func loadBrewHistory() {
        // Simulate some brew history data using the BrewAnalytics models
        brewSessions = [
            BrewSession(
                id: UUID(),
                recipeName: "Classic IPA",
                style: "American IPA",
                brewDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
                batchSize: 23.0,
                targetABV: 5.6,
                targetIBU: 65,
                brewTimeMinutes: 480,
                efficiency: 0.75,
                estimatedCost: 35.50,
                status: .completed
            ),
            BrewSession(
                id: UUID(),
                recipeName: "Belgian Wit",
                style: "Witbier",
                brewDate: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
                batchSize: 20.0,
                targetABV: 4.8,
                targetIBU: 15,
                brewTimeMinutes: 420,
                efficiency: 0.78,
                estimatedCost: 28.75,
                status: .fermenting
            )
        ]
    }
}

// MARK: - Supporting Models
enum BrewTimeframe: CaseIterable {
    case all, thisWeek, thisMonth, thisYear
    
    var displayName: String {
        switch self {
        case .all: return "All Time"
        case .thisWeek: return "This Week"
        case .thisMonth: return "This Month"
        case .thisYear: return "This Year"
        }
    }
}

// MARK: - Brew Session Card
struct BrewSessionCard: View {
    let session: BrewSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.recipeName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(session.brewDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status badge
                HStack(spacing: 4) {
                    Image(systemName: session.status.icon)
                    Text(session.status.displayName)
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(session.status.color)
                .cornerRadius(8)
            }
            
            // Brew details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Style:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(session.style)
                        .font(.caption)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(String(format: "%.1f", session.batchSize))L")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.brewTheme)
                }
                
                HStack {
                    Text("ABV:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.1f", session.targetABV))%")
                        .font(.caption)
                        .fontWeight(.medium)
                    Spacer()
                    if let ibu = session.targetIBU {
                        Text("IBU: \(ibu)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.hopGreen)
                    }
                }
            }
        }
        .padding()
        .background(Color.primaryCard)
        .cornerRadius(12)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    BrewHistoryView()
}
