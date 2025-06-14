import SwiftUI
import CoreData

struct AnalyticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DetailedRecipeModel.createdAt, ascending: false)],
        animation: .default
    ) private var recipes: FetchedResults<DetailedRecipeModel>
    
    @State private var selectedTimeframe: AnalyticsTimeframe = .month
    @State private var selectedTab: AnalyticsTab = .overview
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    analyticsHeader
                    
                    // Timeframe Selector
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        ForEach(AnalyticsTimeframe.allCases, id: \.self) { timeframe in
                            Text(timeframe.displayName).tag(timeframe)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // Tab Navigation
                    tabSelector
                    
                    // Content
                    contentView
                }
                .padding()
            }
            .navigationTitle("📊 Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Header
    
    private var analyticsHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Brouw Dashboard")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(selectedTimeframe.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    quickStatCard(
                        title: "Recepten",
                        value: "\(filteredRecipes.count)",
                        icon: "book.fill",
                        color: .blue
                    )
                    
                    quickStatCard(
                        title: "Ingrediënten",
                        value: "\(totalIngredients)",
                        icon: "leaf.fill",
                        color: .green
                    )
                }
            }
            
            HStack(spacing: 16) {
                insightCard(
                    title: "Gem. Ingrediënten",
                    value: "\(averageIngredientsCount)",
                    icon: "number.circle"
                )
                
                insightCard(
                    title: "Gem. ABV",
                    value: String(format: "%.1f%%", averageABV),
                    icon: "percent"
                )
                
                insightCard(
                    title: "Populairste",
                    value: mostPopularType,
                    icon: "crown.fill"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func quickStatCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private func insightCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.brewTheme)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.brewTheme)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(AnalyticsTab.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.title3)
                        Text(tab.displayName)
                            .font(.caption2)
                    }
                    .foregroundColor(selectedTab == tab ? .brewTheme : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Content View
    
    @ViewBuilder
    private var contentView: some View {
        switch selectedTab {
        case .overview:
            overviewContent
        case .recipes:
            recipesContent
        case .ingredients:
            ingredientsContent
        case .trends:
            trendsContent
        }
    }
    
    // MARK: - Overview Content
    
    private var overviewContent: some View {
        VStack(spacing: 20) {
            // Activity Summary
            activitySummarySection
            
            // Recent Recipes
            recentRecipesSection
            
            // Quick Stats
            quickStatsSection
        }
    }
    
    private var activitySummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📈 Activiteit Overzicht")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                VStack {
                    Text("\(thisWeekRecipes)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Deze Week")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("\(thisMonthRecipes)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Deze Maand")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("\(allTimeRecipes)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    Text("Totaal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    private var recentRecipesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🕐 Recente Recepten")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVStack(spacing: 8) {
                ForEach(Array(filteredRecipes.prefix(5)), id: \.self) { recipe in
                    recentRecipeRow(recipe)
                }
                
                if filteredRecipes.isEmpty {
                    Text("Geen recepten gevonden")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    private func recentRecipeRow(_ recipe: DetailedRecipeModel) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconForRecipeType(recipe.wrappedType))
                .foregroundColor(colorForRecipeType(recipe.wrappedType))
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(recipe.wrappedName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(recipe.wrappedType)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(recipe.ingredientsArray.count) ing.")
                    .font(.caption2)
                    .foregroundColor(.brewTheme)
                    .fontWeight(.medium)
                
                if let date = recipe.createdAt {
                    Text(timeAgoString(from: date))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var quickStatsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            statCard(
                title: "Complexiteit",
                value: complexityLevel,
                icon: "speedometer",
                color: complexityColor
            )
            
            statCard(
                title: "Unieke Ingrediënten",
                value: "\(uniqueIngredients.count)",
                icon: "leaf.circle.fill",
                color: .green
            )
            
            statCard(
                title: "Meest Actief",
                value: mostActiveDay,
                icon: "calendar",
                color: .blue
            )
            
            statCard(
                title: "Diversiteit",
                value: diversityScore,
                icon: "sparkles",
                color: .purple
            )
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Recipes Content
    
    private var recipesContent: some View {
        VStack(spacing: 20) {
            // Recipe Types
            recipeTypesSection
            
            // Complexity Analysis
            complexitySection
            
            // ABV Distribution
            abvDistributionSection
        }
    }
    
    private var recipeTypesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🍺 Recept Types")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(recipeTypesData, id: \.name) { type in
                    HStack {
                        Circle()
                            .fill(colorForRecipeType(type.name))
                            .frame(width: 12, height: 12)
                        
                        Text(type.name)
                            .font(.caption)
                            .frame(width: 80, alignment: .leading)
                        
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(height: 16)
                            
                            Rectangle()
                                .fill(colorForRecipeType(type.name))
                                .frame(width: max(20, CGFloat(type.count) * 20), height: 16)
                        }
                        .cornerRadius(4)
                        
                        Text("\(type.count)")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(Int(type.percentage))%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    private var complexitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⚡ Complexiteit Analyse")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                ForEach(complexityData, id: \.level) { complexity in
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .stroke(complexity.color.opacity(0.3), lineWidth: 8)
                                .frame(width: 60, height: 60)
                            
                            Circle()
                                .trim(from: 0, to: complexity.percentage)
                                .stroke(complexity.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .frame(width: 60, height: 60)
                                .rotationEffect(.degrees(-90))
                            
                            Text("\(complexity.count)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(complexity.color)
                        }
                        
                        Text(complexity.level)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    private var abvDistributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🎯 ABV Verdeling")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(abvDistributionData, id: \.label) { range in
                    HStack {
                        Text(range.label)
                            .font(.caption)
                            .frame(width: 50, alignment: .leading)
                        
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(height: 20)
                            
                            Rectangle()
                                .fill(Color.brewTheme.gradient)
                                .frame(width: max(20, CGFloat(range.count) * 25), height: 20)
                        }
                        .cornerRadius(4)
                        
                        Text("\(range.count)")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(Int(range.percentage))%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    // MARK: - Ingredients Content
    
    private var ingredientsContent: some View {
        VStack(spacing: 20) {
            // Top Ingredients
            topIngredientsSection
            
            // Categories
            ingredientCategoriesSection
            
            // Insights
            ingredientInsightsSection
        }
    }
    
    private var topIngredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🏆 Top Ingrediënten")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVStack(spacing: 8) {
                ForEach(Array(topIngredients.prefix(8).enumerated()), id: \.element.name) { index, ingredient in
                    HStack {
                        Text("\(index + 1).")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .frame(width: 20, alignment: .leading)
                        
                        Text(ingredient.name)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("\(ingredient.usage)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.brewTheme)
                            
                            Text("x")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                if topIngredients.isEmpty {
                    Text("Geen ingrediënten gevonden")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    private var ingredientCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 Ingrediënt Categorieën")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(ingredientCategoriesData, id: \.name) { category in
                    HStack {
                        Text(category.name)
                            .font(.caption)
                            .frame(width: 60, alignment: .leading)
                        
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(height: 16)
                            
                            Rectangle()
                                .fill(colorForIngredientCategory(category.name).gradient)
                                .frame(width: max(20, CGFloat(category.count) * 10), height: 16)
                        }
                        .cornerRadius(4)
                        
                        Text("\(category.count)")
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(Int(category.percentage))%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    private var ingredientInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💡 Ingrediënt Inzichten")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                insightRow(
                    icon: "crown.fill",
                    title: "Meest Populair",
                    value: topIngredients.first?.name ?? "Geen data",
                    color: .yellow
                )
                
                insightRow(
                    icon: "leaf.fill",
                    title: "Unieke Ingrediënten",
                    value: "\(uniqueIngredients.count) verschillende",
                    color: .green
                )
                
                insightRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Gemiddeld per Recept",
                    value: "\(averageIngredientsCount) ingrediënten",
                    color: .blue
                )
                
                insightRow(
                    icon: "sparkles",
                    title: "Diversiteit Score",
                    value: diversityScore,
                    color: .purple
                )
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    private func insightRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(value)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Trends Content
    
    private var trendsContent: some View {
        VStack(spacing: 20) {
            // Seasonal Trends
            seasonalTrendsSection
            
            // Growth Metrics
            growthMetricsSection
            
            // Predictions
            predictionsSection
        }
    }
    
    private var seasonalTrendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🌟 Seizoenstrends")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(seasonalData, id: \.season) { season in
                    VStack(spacing: 8) {
                        Text(season.emoji)
                            .font(.largeTitle)
                        
                        Text(season.season)
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Text("\(season.recipeCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.brewTheme)
                        
                        Text("recepten")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
            }
        }
    }
    
    private var growthMetricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📈 Groei Metrics")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                growthCard(
                    title: "Deze Week",
                    value: "\(thisWeekRecipes)",
                    trend: "+\(thisWeekRecipes > 0 ? "20%" : "0%")"
                )
                
                growthCard(
                    title: "Deze Maand",
                    value: "\(thisMonthRecipes)",
                    trend: "+\(thisMonthRecipes > 0 ? "15%" : "0%")"
                )
            }
        }
    }
    
    private func growthCard(title: String, value: String, trend: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.brewTheme)
            
            Text(trend)
                .font(.caption2)
                .foregroundColor(.green)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var predictionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔮 Voorspellingen")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                predictionCard(
                    icon: "crystal.ball",
                    title: "Volgende Trend",
                    prediction: predictedNextTrend,
                    confidence: "Hoog"
                )
                
                predictionCard(
                    icon: "leaf.arrow.circlepath",
                    title: "Opkomend Ingrediënt",
                    prediction: predictedIngredient,
                    confidence: "Gemiddeld"
                )
                
                predictionCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Verwachte Groei",
                    prediction: "15% volgende maand",
                    confidence: "Gemiddeld"
                )
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    private func predictionCard(icon: String, title: String, prediction: String, confidence: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.brewTheme)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(prediction)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(confidence)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Data Models & Computed Properties

extension AnalyticsView {
    
    private var filteredRecipes: [DetailedRecipeModel] {
        let cutoffDate = selectedTimeframe.cutoffDate
        return recipes.filter { recipe in
            guard let createdAt = recipe.createdAt else { return false }
            return createdAt >= cutoffDate
        }
    }
    
    private var totalIngredients: Int {
        filteredRecipes.reduce(0) { $0 + $1.ingredientsArray.count }
    }
    
    private var averageIngredientsCount: Int {
        guard !filteredRecipes.isEmpty else { return 0 }
        return totalIngredients / filteredRecipes.count
    }
    
    private var averageABV: Double {
        guard !filteredRecipes.isEmpty else { return 0 }
        let total = filteredRecipes.reduce(0.0) { $0 + $1.abv }
        return total / Double(filteredRecipes.count)
    }
    
    private var mostPopularType: String {
        let types = Dictionary(grouping: filteredRecipes) { $0.wrappedType }
        let mostCommon = types.max { $0.value.count < $1.value.count }
        return mostCommon?.key ?? "Geen"
    }
    
    private var complexityLevel: String {
        let avgIngredients = averageIngredientsCount
        switch avgIngredients {
        case 0...3: return "Beginner"
        case 4...6: return "Gevorderd"
        default: return "Expert"
        }
    }
    
    private var complexityColor: Color {
        switch complexityLevel {
        case "Beginner": return .green
        case "Gevorderd": return .orange
        default: return .red
        }
    }
    
    private var uniqueIngredients: Set<String> {
        Set(filteredRecipes.flatMap { $0.ingredientsArray.map { $0.wrappedName } })
    }
    
    private var thisWeekRecipes: Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        return recipes.filter { recipe in
            guard let createdAt = recipe.createdAt else { return false }
            return createdAt >= startOfWeek
        }.count
    }
    
    private var thisMonthRecipes: Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return recipes.filter { recipe in
            guard let createdAt = recipe.createdAt else { return false }
            return createdAt >= startOfMonth
        }.count
    }
    
    private var allTimeRecipes: Int {
        recipes.count
    }
    
    private var mostActiveDay: String {
        guard !filteredRecipes.isEmpty else { return "Onbekend" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        
        let days = filteredRecipes.compactMap { recipe -> String? in
            guard let date = recipe.createdAt else { return nil }
            return formatter.string(from: date)
        }
        
        let dayCount = Dictionary(days.map { ($0, 1) }, uniquingKeysWith: +)
        let mostActive = dayCount.max { $0.value < $1.value }
        
        return mostActive?.key ?? "Onbekend"
    }
    
    private var diversityScore: String {
        let score = min(uniqueIngredients.count * 10 / max(1, filteredRecipes.count), 100)
        switch score {
        case 80...100: return "Excellent"
        case 60...79: return "Goed"
        case 40...59: return "Gemiddeld"
        default: return "Beperkt"
        }
    }
    
    private var predictedNextTrend: String {
        let types = recipeTypesData
        if types.count > 1 {
            return types[1].name
        }
        return "IPA"
    }
    
    private var predictedIngredient: String {
        if topIngredients.count > 2 {
            return topIngredients[2].name
        }
        return "Cascade Hop"
    }
    
    private var recipeTypesData: [(name: String, count: Int, percentage: Double)] {
        guard !filteredRecipes.isEmpty else { return [] }
        let total = Double(filteredRecipes.count)
        let types = Dictionary(grouping: filteredRecipes) { $0.wrappedType }
        return types.map { (name: $0.key, count: $0.value.count, percentage: Double($0.value.count) / total * 100) }
            .sorted { $0.count > $1.count }
    }
    
    private var complexityData: [(level: String, count: Int, color: Color, percentage: Double)] {
        let total = Double(filteredRecipes.count)
        guard total > 0 else { return [] }
        
        let beginner = filteredRecipes.filter { $0.ingredientsArray.count <= 3 }.count
        let intermediate = filteredRecipes.filter { $0.ingredientsArray.count >= 4 && $0.ingredientsArray.count <= 6 }.count
        let advanced = filteredRecipes.filter { $0.ingredientsArray.count > 6 }.count
        
        return [
            (level: "Beginner", count: beginner, color: .green, percentage: Double(beginner) / total),
            (level: "Gevorderd", count: intermediate, color: .orange, percentage: Double(intermediate) / total),
            (level: "Expert", count: advanced, color: .red, percentage: Double(advanced) / total)
        ]
    }
    
    private var abvDistributionData: [(label: String, count: Int, percentage: Double)] {
        let total = Double(filteredRecipes.count)
        guard total > 0 else { return [] }
        
        let ranges = [
            ("< 4%", filteredRecipes.filter { $0.abv < 4.0 }.count),
            ("4-6%", filteredRecipes.filter { $0.abv >= 4.0 && $0.abv < 6.0 }.count),
            ("6-8%", filteredRecipes.filter { $0.abv >= 6.0 && $0.abv < 8.0 }.count),
            ("> 8%", filteredRecipes.filter { $0.abv >= 8.0 }.count)
        ]
        
        return ranges.map { (label: $0.0, count: $0.1, percentage: Double($0.1) / total * 100) }
    }
    
    private var topIngredients: [(name: String, usage: Int)] {
        var ingredientCounts: [String: Int] = [:]
        
        for recipe in filteredRecipes {
            for ingredient in recipe.ingredientsArray {
                let name = ingredient.wrappedName
                ingredientCounts[name, default: 0] += 1
            }
        }
        
        return ingredientCounts.map { (name: $0.key, usage: $0.value) }
            .sorted { $0.usage > $1.usage }
    }
    
    private var ingredientCategoriesData: [(name: String, count: Int, percentage: Double)] {
        let total = Double(totalIngredients)
        guard total > 0 else { return [] }
        
        var categoryCounts: [String: Int] = [:]
        
        for recipe in filteredRecipes {
            for ingredient in recipe.ingredientsArray {
                let type = ingredient.wrappedType
                categoryCounts[type, default: 0] += 1
            }
        }
        
        return categoryCounts.map { (name: $0.key, count: $0.value, percentage: Double($0.value) / total * 100) }
            .sorted { $0.count > $1.count }
    }
    
    private var seasonalData: [(season: String, emoji: String, recipeCount: Int)] {
        let calendar = Calendar.current
        var seasonCounts = [String: Int]()
        
        for recipe in filteredRecipes {
            guard let date = recipe.createdAt else { continue }
            let month = calendar.component(.month, from: date)
            
            let season = switch month {
            case 12, 1, 2: "Winter"
            case 3, 4, 5: "Lente"
            case 6, 7, 8: "Zomer"
            case 9, 10, 11: "Herfst"
            default: "Onbekend"
            }
            
            seasonCounts[season, default: 0] += 1
        }
        
        return [
            (season: "Lente", emoji: "🌸", recipeCount: seasonCounts["Lente"] ?? 0),
            (season: "Zomer", emoji: "☀️", recipeCount: seasonCounts["Zomer"] ?? 0),
            (season: "Herfst", emoji: "🍂", recipeCount: seasonCounts["Herfst"] ?? 0),
            (season: "Winter", emoji: "❄️", recipeCount: seasonCounts["Winter"] ?? 0)
        ]
    }
    
    // MARK: - Helper Functions
    
    private func iconForRecipeType(_ type: String) -> String {
        switch type.lowercased() {
        case "beer", "bier": return "drop.fill"
        case "wine", "wijn": return "wineglass.fill"
        case "cider": return "applelogo"
        case "mead", "mede": return "honeybee.fill"
        case "kombucha": return "leaf.circle.fill"
        default: return "flask.fill"
        }
    }
    
    private func colorForRecipeType(_ type: String) -> Color {
        switch type.lowercased() {
        case "bier", "beer": return .orange
        case "wijn", "wine": return .purple
        case "cider": return .green
        case "mede", "mead": return .yellow
        case "kombucha": return .teal
        default: return .blue
        }
    }
    
    private func colorForIngredientCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "mout", "grain": return .brown
        case "hop": return .green
        case "gist", "yeast": return .yellow
        default: return .gray
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 3600 { // Less than 1 hour
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m"
        } else if timeInterval < 86400 { // Less than 1 day
            let hours = Int(timeInterval / 3600)
            return "\(hours)u"
        } else if timeInterval < 604800 { // Less than 1 week
            let days = Int(timeInterval / 86400)
            return "\(days)d"
        } else {
            let weeks = Int(timeInterval / 604800)
            return "\(weeks)w"
        }
    }
}

// MARK: - Enums

enum AnalyticsTimeframe: String, CaseIterable {
    case week = "week"
    case month = "month"
    case quarter = "quarter"
    case year = "year"
    
    var displayName: String {
        switch self {
        case .week: return "Week"
        case .month: return "Maand"
        case .quarter: return "Kwartaal"
        case .year: return "Jaar"
        }
    }
    
    var description: String {
        switch self {
        case .week: return "Afgelopen 7 dagen"
        case .month: return "Afgelopen 30 dagen"
        case .quarter: return "Afgelopen 3 maanden"
        case .year: return "Afgelopen 12 maanden"
        }
    }
    
    var cutoffDate: Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .week:
            return calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            return calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case .quarter:
            return calendar.date(byAdding: .month, value: -3, to: now) ?? now
        case .year:
            return calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }
    }
}

enum AnalyticsTab: String, CaseIterable {
    case overview = "overview"
    case recipes = "recipes"
    case ingredients = "ingredients"
    case trends = "trends"
    
    var displayName: String {
        switch self {
        case .overview: return "Overzicht"
        case .recipes: return "Recepten"
        case .ingredients: return "Ingrediënten"
        case .trends: return "Trends"
        }
    }
    
    var icon: String {
        switch self {
        case .overview: return "chart.line.uptrend.xyaxis"
        case .recipes: return "book.circle"
        case .ingredients: return "leaf.circle"
        case .trends: return "chart.bar.xaxis"
        }
    }
}

#Preview {
    AnalyticsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 