import Foundation
import SwiftUI

// MARK: - Enhanced Brew Analytics Model
class BrewAnalytics: ObservableObject {
    @Published var brewSessions: [BrewSession] = []
    @Published var statistics: BrewStatistics = BrewStatistics()
    @Published var achievements: [Achievement] = []
    @Published var currentStreak: BrewingStreak = BrewingStreak()
    @Published var personalBests: PersonalBests = PersonalBests()
    
    private let userDefaults = UserDefaults.standard
    private let analyticsKey = "BrewAnalyticsData"
    
    init() {
        loadData()
        loadMockData() // Voor demo doeleinden
        calculateStatistics()
        updateAchievements()
    }
    
    // MARK: - Analytics Functions
    
    func addBrewSession(_ session: BrewSession) {
        Task {
            await MainActor.run {
                brewSessions.append(session)
            }
            
            // Perform calculations in background
            let (stats, achievements, bests) = await calculateAnalytics(for: brewSessions)
            
            await MainActor.run {
                self.statistics = stats
                self.achievements = achievements
                self.personalBests = bests
                saveData()
            }
        }
    }
    
    func updateBrewSession(_ session: BrewSession) {
        Task {
            await MainActor.run {
                if let index = brewSessions.firstIndex(where: { $0.id == session.id }) {
                    brewSessions[index] = session
                }
            }
            
            // Perform calculations in background
            let (stats, achievements, bests) = await calculateAnalytics(for: brewSessions)
            
            await MainActor.run {
                self.statistics = stats
                self.achievements = achievements
                self.personalBests = bests
                saveData()
            }
        }
    }
    
    // MARK: - Background Calculations
    
    private func calculateAnalytics(for sessions: [BrewSession]) async -> (BrewStatistics, [Achievement], PersonalBests) {
        // Create actor to handle concurrent calculations
        actor AnalyticsCalculator {
            private var cache: [String: Any] = [:]
            
            func calculateStatistics(_ sessions: [BrewSession]) -> BrewStatistics {
                if let cached = cache["statistics"] as? BrewStatistics {
                    return cached
                }
                
                var stats = BrewStatistics()
                stats.totalBrews = sessions.count
                stats.completedBrews = sessions.filter { $0.status == .completed }.count
                stats.averageEfficiency = sessions.reduce(0.0) { $0 + $1.efficiency } / Double(sessions.count)
                stats.averageBatchSize = sessions.reduce(0.0) { $0 + $1.batchSize } / Double(sessions.count)
                stats.totalLitersBrewed = sessions.reduce(0.0) { $0 + $1.batchSize }
                
                cache["statistics"] = stats
                return stats
            }
            
            func calculateAchievements(_ sessions: [BrewSession]) -> [Achievement] {
                if let cached = cache["achievements"] as? [Achievement] {
                    return cached
                }
                
                var achievements: [Achievement] = []
                
                // First Brew
                if !sessions.isEmpty {
                    achievements.append(Achievement(
                        id: "first_brew",
                        title: "Eerste Brouwsel",
                        description: "Je eerste brouwsel gemaakt!",
                        icon: "drop.circle",
                        category: .milestone,
                        unlockedDate: sessions.first?.brewDate ?? Date(),
                        rarity: .common
                    ))
                }
                
                // Multiple Brews
                let brewCount = sessions.count
                if brewCount >= 5 {
                    achievements.append(Achievement(
                        id: "brewing_enthusiast",
                        title: "Ervaren Brouwer",
                        description: "5 brouwsels gemaakt",
                        icon: "flame",
                        category: .milestone,
                        unlockedDate: Date(),
                        rarity: .common
                    ))
                }
                
                if brewCount >= 10 {
                    achievements.append(Achievement(
                        id: "master_brewer",
                        title: "Meester Brouwer",
                        description: "10 brouwsels gemaakt",
                        icon: "crown",
                        category: .milestone,
                        unlockedDate: Date(),
                        rarity: .uncommon
                    ))
                }
                
                cache["achievements"] = achievements
                return achievements
            }
            
            func calculatePersonalBests(_ sessions: [BrewSession]) -> PersonalBests {
                if let cached = cache["personalBests"] as? PersonalBests {
                    return cached
                }
                
                var bests = PersonalBests()
                
                for session in sessions where session.status == .completed {
                    if session.efficiency > bests.bestEfficiency {
                        bests.bestEfficiency = session.efficiency
                        bests.bestEfficiencyDate = session.brewDate
                    }
                    
                    if session.batchSize > bests.largestBatch {
                        bests.largestBatch = session.batchSize
                        bests.largestBatchDate = session.brewDate
                    }
                    
                    if session.targetABV > bests.highestABV {
                        bests.highestABV = session.targetABV
                        bests.highestABVDate = session.brewDate
                    }
                    
                    if let ibu = session.targetIBU, ibu > bests.highestIBU {
                        bests.highestIBU = ibu
                        bests.highestIBUDate = session.brewDate
                    }
                    
                    if session.brewTimeMinutes < bests.fastestBrew || bests.fastestBrew == 0 {
                        bests.fastestBrew = session.brewTimeMinutes
                        bests.fastestBrewDate = session.brewDate
                    }
                }
                
                cache["personalBests"] = bests
                return bests
            }
            
            func clearCache() {
                cache.removeAll()
            }
        }
        
        // Create calculator instance
        let calculator = AnalyticsCalculator()
        
        // Perform calculations concurrently
        async let statistics = calculator.calculateStatistics(sessions)
        async let achievements = calculator.calculateAchievements(sessions)
        async let personalBests = calculator.calculatePersonalBests(sessions)
        
        // Wait for all calculations to complete
        return await (statistics, achievements, personalBests)
    }
    
    func calculateStatistics() {
        guard !brewSessions.isEmpty else {
            statistics = BrewStatistics()
            return
        }
        
        let completedSessions = brewSessions.filter { $0.status == .completed }
        let currentYear = Calendar.current.component(.year, from: Date())
        let thisYearSessions = brewSessions.filter { 
            Calendar.current.component(.year, from: $0.brewDate) == currentYear 
        }
        
        // Calculate basic statistics first
        let totalBrews = brewSessions.count
        let completedBrews = completedSessions.count
        let successRate = totalBrews > 0 ? Double(completedBrews) / Double(totalBrews) * 100 : 0
        let averageABV = completedSessions.map { $0.targetABV }.average()
        let averageIBU = completedSessions.compactMap { $0.targetIBU }.average()
        let totalLitersBrewed = completedSessions.map { $0.batchSize }.reduce(0, +)
        let averageBatchSize = completedSessions.map { $0.batchSize }.average()
        let mostBrewedStyle = mostCommonStyle()
        let brewingFrequency = calculateBrewingFrequency()
        let averageBrewTime = completedSessions.map { $0.brewTimeMinutes }.average()
        let thisYearBrews = thisYearSessions.count
        let thisYearLiters = thisYearSessions.filter { $0.status == .completed }.map { $0.batchSize }.reduce(0, +)
        let averageEfficiency = completedSessions.map { $0.efficiency }.average()
        let bestEfficiency = completedSessions.map { $0.efficiency }.max() ?? 0
        
        // Calculate complex statistics
        let styleDistribution = calculateStyleDistribution()
        let monthlyTrends = calculateMonthlyTrends()
        let efficiencyTrend = calculateEfficiencyTrend()
        let costAnalysis = calculateCostAnalysis()
        let seasonalTrends = calculateSeasonalTrends()
        let weeklyActivity = calculateWeeklyActivity()
        
        // Create statistics object
        statistics = BrewStatistics(
            totalBrews: totalBrews,
            completedBrews: completedBrews,
            successRate: successRate,
            averageABV: averageABV,
            averageIBU: averageIBU,
            totalLitersBrewed: totalLitersBrewed,
            averageBatchSize: averageBatchSize,
            mostBrewedStyle: mostBrewedStyle,
            brewingFrequency: brewingFrequency,
            averageBrewTime: averageBrewTime,
            styleDistribution: styleDistribution,
            monthlyTrends: monthlyTrends,
            efficiencyTrend: efficiencyTrend,
            costAnalysis: costAnalysis,
            thisYearBrews: thisYearBrews,
            thisYearLiters: thisYearLiters,
            averageEfficiency: averageEfficiency,
            bestEfficiency: bestEfficiency,
            seasonalTrends: seasonalTrends,
            weeklyActivity: weeklyActivity
        )
        
        updateBrewingStreak()
    }
    
    // MARK: - Achievement System
    
    private func updateAchievements() {
        var newAchievements: [Achievement] = []
        
        // Brewing Milestones
        let totalBrews = brewSessions.count
        let completedBrews = brewSessions.filter { $0.status == .completed }.count
        
        if totalBrews >= 1 && !hasAchievement("first_brew") {
            newAchievements.append(Achievement(
                id: "first_brew",
                title: "Eerste Brouw",
                description: "Je eerste brouwavontuur voltooid!",
                icon: "drop.circle",
                category: .milestone,
                unlockedDate: Date(),
                rarity: .common
            ))
        }
        
        if totalBrews >= 5 && !hasAchievement("brewing_enthusiast") {
            newAchievements.append(Achievement(
                id: "brewing_enthusiast",
                title: "Brouw Enthousiast",
                description: "5 brouwsels gestart",
                icon: "flame",
                category: .milestone,
                unlockedDate: Date(),
                rarity: .common
            ))
        }
        
        if totalBrews >= 10 && !hasAchievement("dedicated_brewer") {
            newAchievements.append(Achievement(
                id: "dedicated_brewer",
                title: "Toegewijde Brouwer",
                description: "10 brouwsels voltooid",
                icon: "star.circle",
                category: .milestone,
                unlockedDate: Date(),
                rarity: .uncommon
            ))
        }
        
        if totalBrews >= 25 && !hasAchievement("master_brewer") {
            newAchievements.append(Achievement(
                id: "master_brewer",
                title: "Meester Brouwer",
                description: "25 brouwsels - je bent een expert!",
                icon: "crown",
                category: .milestone,
                unlockedDate: Date(),
                rarity: .rare
            ))
        }
        
        if totalBrews >= 50 && !hasAchievement("brewing_legend") {
            newAchievements.append(Achievement(
                id: "brewing_legend",
                title: "Brouw Legende",
                description: "50 brouwsels - legendarisch!",
                icon: "trophy",
                category: .milestone,
                unlockedDate: Date(),
                rarity: .legendary
            ))
        }
        
        // Quality Achievements
        let successRate = statistics.successRate
        if successRate >= 90 && completedBrews >= 10 && !hasAchievement("perfectionist") {
            newAchievements.append(Achievement(
                id: "perfectionist",
                title: "Perfectionist",
                description: "90%+ success rate met 10+ brouwsels",
                icon: "checkmark.seal",
                category: .quality,
                unlockedDate: Date(),
                rarity: .rare
            ))
        }
        
        // Efficiency Achievements
        let bestEfficiency = statistics.bestEfficiency
        if bestEfficiency >= 80 && !hasAchievement("efficiency_expert") {
            newAchievements.append(Achievement(
                id: "efficiency_expert",
                title: "Efficiëntie Expert",
                description: "80%+ efficiëntie behaald",
                icon: "speedometer",
                category: .technical,
                unlockedDate: Date(),
                rarity: .uncommon
            ))
        }
        
        // Volume Achievements
        let totalLiters = statistics.totalLitersBrewed
        if totalLiters >= 100 && !hasAchievement("hundred_liters") {
            newAchievements.append(Achievement(
                id: "hundred_liters",
                title: "Honderd Liter Club",
                description: "100+ liter bier gebrouwen",
                icon: "drop.fill",
                category: .volume,
                unlockedDate: Date(),
                rarity: .uncommon
            ))
        }
        
        if totalLiters >= 500 && !hasAchievement("five_hundred_liters") {
            newAchievements.append(Achievement(
                id: "five_hundred_liters",
                title: "Vijfhonderd Liter Meester",
                description: "500+ liter bier gebrouwen",
                icon: "drop.triangle",
                category: .volume,
                unlockedDate: Date(),
                rarity: .rare
            ))
        }
        
        // Style Diversity
        let uniqueStyles = Set(brewSessions.map { $0.style }).count
        if uniqueStyles >= 5 && !hasAchievement("style_explorer") {
            newAchievements.append(Achievement(
                id: "style_explorer",
                title: "Stijl Ontdekkingsreiziger",
                description: "5+ verschillende bierstijlen gebrouwen",
                icon: "map",
                category: .diversity,
                unlockedDate: Date(),
                rarity: .uncommon
            ))
        }
        
        if uniqueStyles >= 10 && !hasAchievement("style_master") {
            newAchievements.append(Achievement(
                id: "style_master",
                title: "Stijl Meester",
                description: "10+ verschillende bierstijlen gebrouwen",
                icon: "star.square",
                category: .diversity,
                unlockedDate: Date(),
                rarity: .rare
            ))
        }
        
        // Consistency Achievements
        if currentStreak.currentStreak >= 5 && !hasAchievement("consistent_brewer") {
            newAchievements.append(Achievement(
                id: "consistent_brewer",
                title: "Consistente Brouwer",
                description: "5 succesvolle brouwsels op rij",
                icon: "arrow.up.circle",
                category: .consistency,
                unlockedDate: Date(),
                rarity: .uncommon
            ))
        }
        
        // Add new achievements
        achievements.append(contentsOf: newAchievements)
        
        // Sort by unlock date (newest first)
        achievements.sort { $0.unlockedDate > $1.unlockedDate }
    }
    
    private func hasAchievement(_ id: String) -> Bool {
        return achievements.contains { $0.id == id }
    }
    
    private func updateBrewingStreak() {
        let completedSessions = brewSessions
            .filter { $0.status == .completed }
            .sorted { $0.brewDate > $1.brewDate }
        
        var currentStreak = 0
        var longestStreak = 0
        var tempStreak = 0
        
        for session in completedSessions {
            if session.status == .completed {
                tempStreak += 1
                longestStreak = max(longestStreak, tempStreak)
                if currentStreak == 0 { currentStreak = tempStreak }
            } else {
                tempStreak = 0
                if currentStreak == tempStreak { currentStreak = 0 }
            }
        }
        
        self.currentStreak = BrewingStreak(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            lastBrewDate: completedSessions.first?.brewDate
        )
    }
    
    private func updatePersonalBests(with session: BrewSession) {
        guard session.status == .completed else { return }
        
        if session.efficiency > personalBests.bestEfficiency {
            personalBests.bestEfficiency = session.efficiency
            personalBests.bestEfficiencyDate = session.brewDate
        }
        
        if session.batchSize > personalBests.largestBatch {
            personalBests.largestBatch = session.batchSize
            personalBests.largestBatchDate = session.brewDate
        }
        
        if session.targetABV > personalBests.highestABV {
            personalBests.highestABV = session.targetABV
            personalBests.highestABVDate = session.brewDate
        }
        
        if let ibu = session.targetIBU, ibu > personalBests.highestIBU {
            personalBests.highestIBU = ibu
            personalBests.highestIBUDate = session.brewDate
        }
        
        if session.brewTimeMinutes < personalBests.fastestBrew || personalBests.fastestBrew == 0 {
            personalBests.fastestBrew = session.brewTimeMinutes
            personalBests.fastestBrewDate = session.brewDate
        }
    }
    
    // MARK: - Enhanced Calculations
    
    private func calculateSeasonalTrends() -> [SeasonalTrend] {
        let calendar = Calendar.current
        let seasons = ["Lente", "Zomer", "Herfst", "Winter"]
        
        return seasons.enumerated().map { index, season in
            let seasonSessions = brewSessions.filter { session in
                let month = calendar.component(.month, from: session.brewDate)
                let seasonIndex = (month - 1) / 3
                return seasonIndex == index
            }
            
            let completedSessions = seasonSessions.filter { $0.status == .completed }
            
            return SeasonalTrend(
                season: season,
                brewCount: seasonSessions.count,
                totalLiters: completedSessions.map { $0.batchSize }.reduce(0, +),
                averageABV: completedSessions.map { $0.targetABV }.average(),
                popularStyle: mostCommonStyleIn(sessions: seasonSessions)
            )
        }
    }
    
    private func calculateWeeklyActivity() -> [WeeklyActivity] {
        let calendar = Calendar.current
        let weekdays = ["Zondag", "Maandag", "Dinsdag", "Woensdag", "Donderdag", "Vrijdag", "Zaterdag"]
        
        return weekdays.enumerated().map { index, day in
            let daySessions = brewSessions.filter { session in
                calendar.component(.weekday, from: session.brewDate) == index + 1
            }
            
            return WeeklyActivity(
                day: day,
                brewCount: daySessions.count,
                percentage: brewSessions.isEmpty ? 0 : Double(daySessions.count) / Double(brewSessions.count) * 100
            )
        }
    }
    
    private func mostCommonStyleIn(sessions: [BrewSession]) -> String {
        let styles = sessions.map { $0.style }
        let counts = Dictionary(grouping: styles, by: { $0 }).mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key ?? "Geen data"
    }
    
    // MARK: - Data Persistence
    
    private func saveData() {
        let data = AnalyticsData(
            brewSessions: brewSessions,
            achievements: achievements,
            personalBests: personalBests
        )
        
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults.set(encoded, forKey: analyticsKey)
        }
    }
    
    private func loadData() {
        if let data = userDefaults.data(forKey: analyticsKey),
           let decoded = try? JSONDecoder().decode(AnalyticsData.self, from: data) {
            brewSessions = decoded.brewSessions
            achievements = decoded.achievements
            personalBests = decoded.personalBests
        }
    }
    
    // MARK: - Helper Calculations
    
    private func mostCommonStyle() -> String {
        let styles = brewSessions.map { $0.style }
        let counts = Dictionary(grouping: styles, by: { $0 }).mapValues { $0.count }
        return counts.max(by: { $0.value < $1.value })?.key ?? "Geen data"
    }
    
    private func calculateBrewingFrequency() -> Double {
        guard let firstBrew = brewSessions.map({ $0.brewDate }).min(),
              let lastBrew = brewSessions.map({ $0.brewDate }).max() else {
            return 0
        }
        
        let daysBetween = Calendar.current.dateComponents([.day], from: firstBrew, to: lastBrew).day ?? 0
        let weeks = Double(daysBetween) / 7.0
        
        return weeks > 0 ? Double(brewSessions.count) / weeks : 0
    }
    
    private func calculateStyleDistribution() -> [StyleDistribution] {
        let groupedByStyle = Dictionary(grouping: brewSessions, by: { $0.style })
        return groupedByStyle.map { style, sessions in
            StyleDistribution(
                style: style,
                count: sessions.count,
                percentage: Double(sessions.count) / Double(brewSessions.count) * 100
            )
        }.sorted { $0.count > $1.count }
    }
    
    private func calculateMonthlyTrends() -> [MonthlyTrend] {
        let calendar = Calendar.current
        let groupedByMonth = Dictionary(grouping: brewSessions) { session in
            calendar.dateInterval(of: .month, for: session.brewDate)?.start ?? session.brewDate
        }
        
        return groupedByMonth.map { month, sessions in
            let completedSessions = sessions.filter { $0.status == .completed }
            
            return MonthlyTrend(
                month: month,
                brewCount: sessions.count,
                totalLiters: completedSessions.map { $0.batchSize }.reduce(0, +),
                averageABV: completedSessions.map { $0.targetABV }.average(),
                successRate: sessions.isEmpty ? 0 : Double(completedSessions.count) / Double(sessions.count) * 100
            )
        }.sorted { $0.month < $1.month }
    }
    
    private func calculateEfficiencyTrend() -> [EfficiencyPoint] {
        return brewSessions.enumerated().map { index, session in
            EfficiencyPoint(
                brewNumber: index + 1,
                efficiency: session.efficiency,
                date: session.brewDate
            )
        }
    }
    
    private func calculateCostAnalysis() -> CostAnalysis {
        let completedSessions = brewSessions.filter { $0.status == .completed }
        let totalCost = completedSessions.map { $0.estimatedCost }.reduce(0, +)
        let totalLiters = completedSessions.map { $0.batchSize }.reduce(0, +)
        
        return CostAnalysis(
            totalInvestment: totalCost,
            costPerLiter: totalLiters > 0 ? totalCost / totalLiters : 0,
            averageBatchCost: completedSessions.isEmpty ? 0 : totalCost / Double(completedSessions.count),
            mostExpensiveStyle: calculateMostExpensiveStyle(),
            costTrend: calculateCostTrend()
        )
    }
    
    private func calculateMostExpensiveStyle() -> String {
        let stylesCosts = Dictionary(grouping: brewSessions.filter { $0.status == .completed }, by: { $0.style })
            .mapValues { sessions in
                sessions.map { $0.estimatedCost }.average()
            }
        
        return stylesCosts.max(by: { $0.value < $1.value })?.key ?? "Geen data"
    }
    
    private func calculateCostTrend() -> [CostTrendPoint] {
        return brewSessions.enumerated().map { index, session in
            CostTrendPoint(
                brewNumber: index + 1,
                cost: session.estimatedCost,
                costPerLiter: session.batchSize > 0 ? session.estimatedCost / session.batchSize : 0,
                date: session.brewDate
            )
        }
    }
    
    // MARK: - Mock Data
    private func loadMockData() {
        let mockSessions = [
            BrewSession(
                recipeName: "Klassiek Pilsner",
                style: "Czech Pilsner",
                brewDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
                batchSize: 23,
                targetABV: 4.8,
                targetIBU: 35,
                brewTimeMinutes: 240,
                efficiency: 72,
                estimatedCost: 28.50,
                status: .completed
            ),
            BrewSession(
                recipeName: "American IPA",
                style: "American IPA",
                brewDate: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
                batchSize: 20,
                targetABV: 6.2,
                targetIBU: 65,
                brewTimeMinutes: 300,
                efficiency: 68,
                estimatedCost: 35.00,
                status: .completed
            ),
            BrewSession(
                recipeName: "Wheat Beer",
                style: "Hefeweizen",
                brewDate: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
                batchSize: 25,
                targetABV: 5.2,
                targetIBU: 12,
                brewTimeMinutes: 220,
                efficiency: 75,
                estimatedCost: 22.75,
                status: .completed
            ),
            BrewSession(
                recipeName: "Porter",
                style: "Robust Porter",
                brewDate: Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date()) ?? Date(),
                batchSize: 23,
                targetABV: 5.8,
                targetIBU: 28,
                brewTimeMinutes: 280,
                efficiency: 70,
                estimatedCost: 31.20,
                status: .inProgress
            ),
            BrewSession(
                recipeName: "Saison",
                style: "Belgian Saison",
                brewDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                batchSize: 20,
                targetABV: 6.5,
                targetIBU: 22,
                brewTimeMinutes: 320,
                efficiency: 73,
                estimatedCost: 26.80,
                status: .fermenting
            )
        ]
        
        brewSessions = mockSessions
    }
}

// MARK: - Data Models

struct BrewSession: Identifiable, Codable {
    let id: UUID
    let recipeName: String
    let style: String
    let brewDate: Date
    let batchSize: Double // liters
    let targetABV: Double
    let targetIBU: Int?
    let brewTimeMinutes: Int
    let efficiency: Double // percentage
    let estimatedCost: Double
    let status: BrewStatus
    
    init(id: UUID = UUID(), recipeName: String, style: String, brewDate: Date, batchSize: Double, targetABV: Double, targetIBU: Int?, brewTimeMinutes: Int, efficiency: Double, estimatedCost: Double, status: BrewStatus) {
        self.id = id
        self.recipeName = recipeName
        self.style = style
        self.brewDate = brewDate
        self.batchSize = batchSize
        self.targetABV = targetABV
        self.targetIBU = targetIBU
        self.brewTimeMinutes = brewTimeMinutes
        self.efficiency = efficiency
        self.estimatedCost = estimatedCost
        self.status = status
    }
}

enum BrewStatus: String, CaseIterable, Codable {
    case planned = "Gepland"
    case inProgress = "Bezig"
    case fermenting = "Gisting"
    case conditioning = "Rijping"
    case completed = "Voltooid"
    case failed = "Mislukt"
    
    var color: Color {
        switch self {
        case .planned: return .gray
        case .inProgress: return .blue
        case .fermenting: return .orange
        case .conditioning: return .yellow
        case .completed: return .green
        case .failed: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .planned: return "calendar"
        case .inProgress: return "play.circle"
        case .fermenting: return "drop.circle"
        case .conditioning: return "hourglass"
        case .completed: return "checkmark.circle"
        case .failed: return "xmark.circle"
        }
    }
}

struct BrewStatistics {
    var totalBrews: Int = 0
    var completedBrews: Int = 0
    var successRate: Double = 0
    var averageABV: Double = 0
    var averageIBU: Double = 0
    var totalLitersBrewed: Double = 0
    var averageBatchSize: Double = 0
    var mostBrewedStyle: String = ""
    var brewingFrequency: Double = 0 // brews per week
    var averageBrewTime: Double = 0 // minutes
    
    var styleDistribution: [StyleDistribution] = []
    var monthlyTrends: [MonthlyTrend] = []
    var efficiencyTrend: [EfficiencyPoint] = []
    var costAnalysis: CostAnalysis = CostAnalysis()
    var thisYearBrews: Int = 0
    var thisYearLiters: Double = 0
    var averageEfficiency: Double = 0
    var bestEfficiency: Double = 0
    var seasonalTrends: [SeasonalTrend] = []
    var weeklyActivity: [WeeklyActivity] = []
    
    init() {
        // Default initializer with all default values
    }
    
    init(totalBrews: Int, completedBrews: Int, successRate: Double, averageABV: Double, averageIBU: Double, totalLitersBrewed: Double, averageBatchSize: Double, mostBrewedStyle: String, brewingFrequency: Double, averageBrewTime: Double, styleDistribution: [StyleDistribution], monthlyTrends: [MonthlyTrend], efficiencyTrend: [EfficiencyPoint], costAnalysis: CostAnalysis, thisYearBrews: Int, thisYearLiters: Double, averageEfficiency: Double, bestEfficiency: Double, seasonalTrends: [SeasonalTrend], weeklyActivity: [WeeklyActivity]) {
        self.totalBrews = totalBrews
        self.completedBrews = completedBrews
        self.successRate = successRate
        self.averageABV = averageABV
        self.averageIBU = averageIBU
        self.totalLitersBrewed = totalLitersBrewed
        self.averageBatchSize = averageBatchSize
        self.mostBrewedStyle = mostBrewedStyle
        self.brewingFrequency = brewingFrequency
        self.averageBrewTime = averageBrewTime
        self.styleDistribution = styleDistribution
        self.monthlyTrends = monthlyTrends
        self.efficiencyTrend = efficiencyTrend
        self.costAnalysis = costAnalysis
        self.thisYearBrews = thisYearBrews
        self.thisYearLiters = thisYearLiters
        self.averageEfficiency = averageEfficiency
        self.bestEfficiency = bestEfficiency
        self.seasonalTrends = seasonalTrends
        self.weeklyActivity = weeklyActivity
    }
}

struct StyleDistribution: Identifiable, Codable {
    var id = UUID()
    let style: String
    let count: Int
    let percentage: Double
    
    init(style: String, count: Int, percentage: Double) {
        self.id = UUID()
        self.style = style
        self.count = count
        self.percentage = percentage
    }
}

struct MonthlyTrend: Identifiable, Codable {
    var id = UUID()
    let month: Date
    let brewCount: Int
    let totalLiters: Double
    let averageABV: Double
    let successRate: Double
    
    init(month: Date, brewCount: Int, totalLiters: Double, averageABV: Double, successRate: Double) {
        self.id = UUID()
        self.month = month
        self.brewCount = brewCount
        self.totalLiters = totalLiters
        self.averageABV = averageABV
        self.successRate = successRate
    }
}

struct EfficiencyPoint: Identifiable, Codable {
    var id = UUID()
    let brewNumber: Int
    let efficiency: Double
    let date: Date
    
    init(brewNumber: Int, efficiency: Double, date: Date) {
        self.id = UUID()
        self.brewNumber = brewNumber
        self.efficiency = efficiency
        self.date = date
    }
}

struct CostAnalysis {
    var totalInvestment: Double = 0
    var costPerLiter: Double = 0
    var averageBatchCost: Double = 0
    var mostExpensiveStyle: String = ""
    var costTrend: [CostTrendPoint] = []
}

struct CostTrendPoint: Identifiable, Codable {
    var id = UUID()
    let brewNumber: Int
    let cost: Double
    let costPerLiter: Double
    let date: Date
    
    init(brewNumber: Int, cost: Double, costPerLiter: Double, date: Date) {
        self.id = UUID()
        self.brewNumber = brewNumber
        self.cost = cost
        self.costPerLiter = costPerLiter
        self.date = date
    }
}

// MARK: - Enhanced Data Models

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let unlockedDate: Date
    let rarity: AchievementRarity
    
    var rarityColor: Color {
        switch rarity {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
}

enum AchievementCategory: String, CaseIterable, Codable {
    case milestone = "Mijlpaal"
    case quality = "Kwaliteit"
    case technical = "Technisch"
    case volume = "Volume"
    case diversity = "Diversiteit"
    case consistency = "Consistentie"
    case speed = "Snelheid"
    case innovation = "Innovatie"
    
    var icon: String {
        switch self {
        case .milestone: return "flag.checkered"
        case .quality: return "star.circle"
        case .technical: return "gear"
        case .volume: return "drop.fill"
        case .diversity: return "rainbow"
        case .consistency: return "arrow.clockwise"
        case .speed: return "timer"
        case .innovation: return "lightbulb"
        }
    }
    
    var color: Color {
        switch self {
        case .milestone: return .blue
        case .quality: return .green
        case .technical: return .orange
        case .volume: return .cyan
        case .diversity: return .purple
        case .consistency: return .indigo
        case .speed: return .red
        case .innovation: return .yellow
        }
    }
}

enum AchievementRarity: String, CaseIterable, Codable {
    case common = "Gewoon"
    case uncommon = "Ongewoon"
    case rare = "Zeldzaam"
    case epic = "Episch"
    case legendary = "Legendarisch"
    
    var multiplier: Double {
        switch self {
        case .common: return 1.0
        case .uncommon: return 1.5
        case .rare: return 2.0
        case .epic: return 3.0
        case .legendary: return 5.0
        }
    }
}

struct BrewingStreak: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastBrewDate: Date?
    
    var isActive: Bool {
        guard let lastDate = lastBrewDate else { return false }
        let daysSinceLastBrew = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
        return daysSinceLastBrew <= 30 // Consider streak active if last brew was within 30 days
    }
}

struct PersonalBests: Codable {
    var bestEfficiency: Double = 0
    var bestEfficiencyDate: Date?
    var largestBatch: Double = 0
    var largestBatchDate: Date?
    var highestABV: Double = 0
    var highestABVDate: Date?
    var highestIBU: Int = 0
    var highestIBUDate: Date?
    var fastestBrew: Int = 0 // minutes
    var fastestBrewDate: Date?
}

struct SeasonalTrend: Identifiable, Codable {
    var id = UUID()
    let season: String
    let brewCount: Int
    let totalLiters: Double
    let averageABV: Double
    let popularStyle: String
    
    init(season: String, brewCount: Int, totalLiters: Double, averageABV: Double, popularStyle: String) {
        self.id = UUID()
        self.season = season
        self.brewCount = brewCount
        self.totalLiters = totalLiters
        self.averageABV = averageABV
        self.popularStyle = popularStyle
    }
}

struct WeeklyActivity: Identifiable, Codable {
    var id = UUID()
    let day: String
    let brewCount: Int
    let percentage: Double
    
    init(day: String, brewCount: Int, percentage: Double) {
        self.id = UUID()
        self.day = day
        self.brewCount = brewCount
        self.percentage = percentage
    }
}

struct AnalyticsData: Codable {
    let brewSessions: [BrewSession]
    let achievements: [Achievement]
    let personalBests: PersonalBests
}

// MARK: - Extensions
extension Array where Element == Double {
    func average() -> Double {
        guard !isEmpty else { return 0 }
        let sum = reduce(0, +)
        let result = sum / Double(count)
        return result.isNaN || result.isInfinite ? 0 : result
    }
}

extension Array where Element == Int {
    func average() -> Double {
        guard !isEmpty else { return 0 }
        let sum = Double(reduce(0, +))
        let result = sum / Double(count)
        return result.isNaN || result.isInfinite ? 0 : result
    }
} 