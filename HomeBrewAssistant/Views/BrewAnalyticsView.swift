import SwiftUI
import Charts

struct BrewAnalyticsView: View {
    @StateObject private var analytics = BrewAnalytics()
    @State private var selectedTab = 0
    @State private var showingAchievements = false
    @State private var showingPersonalBests = false
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Enhanced Header with Quick Stats
                headerSection
                
                // Tab Picker
                Picker("Analytics View", selection: $selectedTab) {
                    Text(localizationManager.localized("analytics.overview")).tag(0)
                    Text(localizationManager.localized("analytics.trends")).tag(1)
                    Text(localizationManager.localized("analytics.costs")).tag(2)
                    Text("Prestaties").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Content
                TabView(selection: $selectedTab) {
                    overviewTab
                        .tag(0)
                    
                    trendsTab
                        .tag(1)
                    
                    costsTab
                        .tag(2)
                    
                    achievementsTab
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle(localizationManager.localized("analytics.title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingAchievements = true }) {
                            Label("Prestaties", systemImage: "trophy")
                        }
                        
                        Button(action: { showingPersonalBests = true }) {
                            Label("Persoonlijke Records", systemImage: "star.circle")
                        }
                        
                        Button(action: { }) {
                            Label("Export Data", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAchievements) {
                AchievementsView(analytics: analytics)
            }
            .sheet(isPresented: $showingPersonalBests) {
                PersonalBestsView(analytics: analytics)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                // Current Streak
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: analytics.currentStreak.isActive ? "flame.fill" : "flame")
                            .foregroundColor(analytics.currentStreak.isActive ? .orange : .gray)
                        Text("Streak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("\(analytics.currentStreak.currentStreak)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(analytics.currentStreak.isActive ? .orange : .primary)
                }
                
                Spacer()
                
                // This Year Stats
                VStack(alignment: .center, spacing: 4) {
                    Text("Dit Jaar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 16) {
                        VStack(spacing: 2) {
                            Text("\(analytics.statistics.thisYearBrews)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.brewTheme)
                            Text("brouwsels")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 2) {
                            Text("\(String(format: "%.0f", analytics.statistics.thisYearLiters))L")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.brewTheme)
                            Text("liter")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Recent Achievement
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Text("Nieuwste")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                    }
                    
                    if let recentAchievement = analytics.achievements.first {
                        Text(recentAchievement.title)
                            .font(.caption)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.trailing)
                            .lineLimit(2)
                    } else {
                        Text("Geen prestaties")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            
            // Progress to next milestone
            if analytics.statistics.totalBrews < 50 {
                nextMilestoneProgress
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    private var nextMilestoneProgress: some View {
        let currentBrews = analytics.statistics.totalBrews
        let nextMilestone: Int
        let milestoneTitle: String
        
        if currentBrews < 5 {
            nextMilestone = 5
            milestoneTitle = "Brouw Enthousiast"
        } else if currentBrews < 10 {
            nextMilestone = 10
            milestoneTitle = "Toegewijde Brouwer"
        } else if currentBrews < 25 {
            nextMilestone = 25
            milestoneTitle = "Meester Brouwer"
        } else {
            nextMilestone = 50
            milestoneTitle = "Brouw Legende"
        }
        
        let progress = Double(currentBrews) / Double(nextMilestone)
        
        return VStack(spacing: 6) {
            HStack {
                Text("Volgende: \(milestoneTitle)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(currentBrews)/\(nextMilestone)")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .brewTheme))
        }
        .padding(.horizontal)
    }
    
    // MARK: - Overview Tab
    
    private var overviewTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Key Statistics Cards
                keyStatisticsGrid
                
                // Recent Brews
                recentBrewsSection
                
                // Style Distribution
                styleDistributionSection
            }
            .padding()
        }
    }
    
    private var keyStatisticsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
            StatCard(
                title: localizationManager.localized("analytics.total_brews"),
                value: "\(analytics.statistics.totalBrews)",
                icon: "drop.circle",
                color: .blue
            )
            
            StatCard(
                title: localizationManager.localized("analytics.success_rate"),
                value: "\(String(format: "%.1f", analytics.statistics.successRate))%",
                icon: "checkmark.circle",
                color: .green
            )
            
            StatCard(
                title: localizationManager.localized("analytics.total_liters"),
                value: "\(String(format: "%.0f", analytics.statistics.totalLitersBrewed))L",
                icon: "drop.fill",
                color: .orange
            )
            
            StatCard(
                title: localizationManager.localized("analytics.average_abv"),
                value: "\(String(format: "%.1f", analytics.statistics.averageABV))%",
                icon: "speedometer",
                color: .purple
            )
            
            StatCard(
                title: localizationManager.localized("analytics.brewing_frequency"),
                value: "\(String(format: "%.1f", analytics.statistics.brewingFrequency))",
                subtitle: localizationManager.localized("analytics.brews_per_week"),
                icon: "calendar",
                color: .red
            )
            
            StatCard(
                title: localizationManager.localized("analytics.most_brewed_style"),
                value: analytics.statistics.mostBrewedStyle,
                icon: "star.circle",
                color: .yellow
            )
        }
    }
    
    private var recentBrewsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Recente Brouwsels")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            ForEach(analytics.brewSessions.prefix(3)) { session in
                BrewSessionRow(session: session)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var styleDistributionSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(localizationManager.localized("analytics.style_distribution"))
                .font(.title2)
                .fontWeight(.bold)
            
            if !analytics.statistics.styleDistribution.isEmpty {
                VStack(spacing: 8) {
                    ForEach(analytics.statistics.styleDistribution.prefix(5)) { style in
                        HStack {
                            Text(style.style)
                                .font(.body)
                            
                            Spacer()
                            
                            Text("\(style.count)")
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Text("(\(String(format: "%.1f", style.percentage))%)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            } else {
                Text(localizationManager.localized("chart.no_data"))
                    .foregroundColor(.secondary)
                    .font(.body)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Trends Tab
    
    private var trendsTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Monthly Trends Chart
                monthlyTrendsChart
                
                // Efficiency Trend Chart
                efficiencyTrendChart
            }
            .padding()
        }
    }
    
    private var monthlyTrendsChart: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(localizationManager.localized("analytics.monthly_trends"))
                .font(.title2)
                .fontWeight(.bold)
            
            if !analytics.statistics.monthlyTrends.isEmpty {
                Chart(analytics.statistics.monthlyTrends) { trend in
                    BarMark(
                        x: .value("Month", trend.month, unit: .month),
                        y: .value("Brews", trend.brewCount)
                    )
                    .foregroundStyle(.blue)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { _ in
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                    }
                }
            } else {
                Text(localizationManager.localized("chart.no_data"))
                    .foregroundColor(.secondary)
                    .font(.body)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var efficiencyTrendChart: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(localizationManager.localized("analytics.efficiency_trend"))
                .font(.title2)
                .fontWeight(.bold)
            
            if !analytics.statistics.efficiencyTrend.isEmpty {
                Chart(analytics.statistics.efficiencyTrend) { point in
                    LineMark(
                        x: .value("Brew", point.brewNumber),
                        y: .value("Efficiency", point.efficiency)
                    )
                    .foregroundStyle(.orange)
                    .symbol(.circle)
                }
                .frame(height: 200)
                .chartYScale(domain: 50...100)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                    }
                }
            } else {
                Text(localizationManager.localized("chart.no_data"))
                    .foregroundColor(.secondary)
                    .font(.body)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Costs Tab
    
    private var costsTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Cost Statistics
                costStatisticsGrid
                
                // Cost Trend Chart
                costTrendChart
            }
            .padding()
        }
    }
    
    // MARK: - Achievements Tab
    
    private var achievementsTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Achievement Summary
                achievementSummarySection
                
                // Recent Achievements
                recentAchievementsSection
                
                // Personal Bests
                personalBestsSection
                
                // Seasonal & Weekly Trends
                activityPatternsSection
            }
            .padding()
        }
    }
    
    private var achievementSummarySection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("🏆 Prestatie Overzicht")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatCard(
                    title: "Totaal Prestaties",
                    value: "\(analytics.achievements.count)",
                    icon: "trophy.fill",
                    color: .yellow
                )
                
                StatCard(
                    title: "Huidige Streak",
                    value: "\(analytics.currentStreak.currentStreak)",
                    subtitle: analytics.currentStreak.isActive ? "Actief" : "Inactief",
                    icon: analytics.currentStreak.isActive ? "flame.fill" : "flame",
                    color: analytics.currentStreak.isActive ? .orange : .gray
                )
                
                StatCard(
                    title: "Langste Streak",
                    value: "\(analytics.currentStreak.longestStreak)",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
                
                StatCard(
                    title: "Prestatie Score",
                    value: "\(Int(analytics.achievements.map { $0.rarity.multiplier }.reduce(0, +)))",
                    icon: "star.circle.fill",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var recentAchievementsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("🎯 Recente Prestaties")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("Alle Prestaties") {
                    showingAchievements = true
                }
                .font(.caption)
                .foregroundColor(.brewTheme)
            }
            
            if analytics.achievements.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trophy")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("Nog geen prestaties behaald")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Start met brouwen om je eerste prestatie te behalen!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(analytics.achievements.prefix(3)) { achievement in
                    AchievementRow(achievement: achievement)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var personalBestsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("⭐ Persoonlijke Records")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("Alle Records") {
                    showingPersonalBests = true
                }
                .font(.caption)
                .foregroundColor(.brewTheme)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                if analytics.personalBests.bestEfficiency > 0 {
                    StatCard(
                        title: "Beste Efficiëntie",
                        value: "\(String(format: "%.1f", analytics.personalBests.bestEfficiency))%",
                        icon: "speedometer",
                        color: .green
                    )
                }
                
                if analytics.personalBests.largestBatch > 0 {
                    StatCard(
                        title: "Grootste Batch",
                        value: "\(String(format: "%.0f", analytics.personalBests.largestBatch))L",
                        icon: "drop.fill",
                        color: .blue
                    )
                }
                
                if analytics.personalBests.highestABV > 0 {
                    StatCard(
                        title: "Hoogste ABV",
                        value: "\(String(format: "%.1f", analytics.personalBests.highestABV))%",
                        icon: "flame.fill",
                        color: .red
                    )
                }
                
                if analytics.personalBests.fastestBrew > 0 {
                    StatCard(
                        title: "Snelste Brouw",
                        value: "\(analytics.personalBests.fastestBrew / 60)u \(analytics.personalBests.fastestBrew % 60)m",
                        icon: "timer",
                        color: .orange
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var activityPatternsSection: some View {
        VStack(spacing: 20) {
            // Seasonal Trends
            VStack(alignment: .leading, spacing: 15) {
                Text("🌍 Seizoenspatronen")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if !analytics.statistics.seasonalTrends.isEmpty {
                    Chart(analytics.statistics.seasonalTrends) { trend in
                        BarMark(
                            x: .value("Seizoen", trend.season),
                            y: .value("Brouwsels", trend.brewCount)
                        )
                        .foregroundStyle(.brewTheme)
                    }
                    .frame(height: 150)
                } else {
                    Text("Geen seizoensdata beschikbaar")
                        .foregroundColor(.secondary)
                        .font(.body)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Weekly Activity
            VStack(alignment: .leading, spacing: 15) {
                Text("📅 Weekpatroon")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if !analytics.statistics.weeklyActivity.isEmpty {
                    Chart(analytics.statistics.weeklyActivity) { activity in
                        BarMark(
                            x: .value("Dag", activity.day),
                            y: .value("Percentage", activity.percentage)
                        )
                        .foregroundStyle(.orange)
                    }
                    .frame(height: 150)
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisValueLabel()
                        }
                    }
                } else {
                    Text("Geen weekdata beschikbaar")
                        .foregroundColor(.secondary)
                        .font(.body)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var costStatisticsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
            StatCard(
                title: localizationManager.localized("analytics.total_investment"),
                value: "€\(String(format: "%.2f", analytics.statistics.costAnalysis.totalInvestment))",
                icon: "eurosign.circle",
                color: .green
            )
            
            StatCard(
                title: localizationManager.localized("analytics.cost_per_liter"),
                value: "€\(String(format: "%.2f", analytics.statistics.costAnalysis.costPerLiter))",
                icon: "drop.circle",
                color: .blue
            )
            
            StatCard(
                title: localizationManager.localized("analytics.average_batch_cost"),
                value: "€\(String(format: "%.2f", analytics.statistics.costAnalysis.averageBatchCost))",
                icon: "chart.bar.fill",
                color: .orange
            )
            
            StatCard(
                title: localizationManager.localized("analytics.most_expensive_style"),
                value: analytics.statistics.costAnalysis.mostExpensiveStyle,
                icon: "star.circle",
                color: .red
            )
        }
    }
    
    private var costTrendChart: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(localizationManager.localized("analytics.cost_trend"))
                .font(.title2)
                .fontWeight(.bold)
            
            if !analytics.statistics.costAnalysis.costTrend.isEmpty {
                Chart(analytics.statistics.costAnalysis.costTrend) { point in
                    LineMark(
                        x: .value("Brew", point.brewNumber),
                        y: .value("Cost per Liter", point.costPerLiter)
                    )
                    .foregroundStyle(.green)
                    .symbol(.circle)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                    }
                }
            } else {
                Text(localizationManager.localized("chart.no_data"))
                    .foregroundColor(.secondary)
                    .font(.body)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct BrewSessionRow: View {
    let session: BrewSession
    
    var body: some View {
        HStack {
            // Status indicator
            Image(systemName: session.status.icon)
                .foregroundColor(session.status.color)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.recipeName)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(session.style)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(session.brewDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(String(format: "%.0f", session.batchSize))L")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.brewTheme)
                
                Text(session.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(session.status.color.opacity(0.2))
                    .foregroundColor(session.status.color)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

// MARK: - Achievement Row View

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 12) {
            // Achievement Icon
            ZStack {
                Circle()
                    .fill(achievement.rarityColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.rarityColor)
            }
            
            // Achievement Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(achievement.title)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(achievement.rarity.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(achievement.rarityColor.opacity(0.2))
                        .foregroundColor(achievement.rarityColor)
                        .cornerRadius(4)
                }
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(achievement.unlockedDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

// MARK: - Achievements View

struct AchievementsView: View {
    let analytics: BrewAnalytics
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: AchievementCategory? = nil
    
    var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return analytics.achievements.filter { $0.category == category }
        }
        return analytics.achievements
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button("Alle") {
                            selectedCategory = nil
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedCategory == nil ? Color.brewTheme : Color(.systemGray5))
                        .foregroundColor(selectedCategory == nil ? .white : .primary)
                        .cornerRadius(20)
                        
                        ForEach(AchievementCategory.allCases, id: \.self) { category in
                            Button(category.rawValue) {
                                selectedCategory = category
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? Color.brewTheme : Color(.systemGray5))
                            .foregroundColor(selectedCategory == category ? .white : .primary)
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                // Achievements List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if filteredAchievements.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "trophy")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                
                                Text("Geen prestaties in deze categorie")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Blijf brouwen om nieuwe prestaties te behalen!")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 50)
                        } else {
                            ForEach(filteredAchievements) { achievement in
                                AchievementRow(achievement: achievement)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("🏆 Prestaties")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Personal Bests View

struct PersonalBestsView: View {
    let analytics: BrewAnalytics
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Personal Records Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 16) {
                        if analytics.personalBests.bestEfficiency > 0 {
                            PersonalBestCard(
                                title: "Beste Efficiëntie",
                                value: "\(String(format: "%.1f", analytics.personalBests.bestEfficiency))%",
                                date: analytics.personalBests.bestEfficiencyDate,
                                icon: "speedometer",
                                color: .green
                            )
                        }
                        
                        if analytics.personalBests.largestBatch > 0 {
                            PersonalBestCard(
                                title: "Grootste Batch",
                                value: "\(String(format: "%.0f", analytics.personalBests.largestBatch))L",
                                date: analytics.personalBests.largestBatchDate,
                                icon: "drop.fill",
                                color: .blue
                            )
                        }
                        
                        if analytics.personalBests.highestABV > 0 {
                            PersonalBestCard(
                                title: "Hoogste ABV",
                                value: "\(String(format: "%.1f", analytics.personalBests.highestABV))%",
                                date: analytics.personalBests.highestABVDate,
                                icon: "flame.fill",
                                color: .red
                            )
                        }
                        
                        if analytics.personalBests.highestIBU > 0 {
                            PersonalBestCard(
                                title: "Hoogste IBU",
                                value: "\(analytics.personalBests.highestIBU)",
                                date: analytics.personalBests.highestIBUDate,
                                icon: "leaf.fill",
                                color: .orange
                            )
                        }
                        
                        if analytics.personalBests.fastestBrew > 0 {
                            PersonalBestCard(
                                title: "Snelste Brouw",
                                value: "\(analytics.personalBests.fastestBrew / 60)u \(analytics.personalBests.fastestBrew % 60)m",
                                date: analytics.personalBests.fastestBrewDate,
                                icon: "timer",
                                color: .purple
                            )
                        }
                    }
                    
                    if analytics.personalBests.bestEfficiency == 0 {
                        VStack(spacing: 16) {
                            Image(systemName: "star.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("Nog geen persoonlijke records")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Voltooi je eerste brouwsel om records bij te houden!")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 50)
                    }
                }
                .padding()
            }
            .navigationTitle("⭐ Persoonlijke Records")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PersonalBestCard: View {
    let title: String
    let value: String
    let date: Date?
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                if let date = date {
                    Text("Behaald op \(date, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "crown.fill")
                .font(.title2)
                .foregroundColor(.yellow)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    BrewAnalyticsView()
        .environmentObject(LocalizationManager.shared)
} 