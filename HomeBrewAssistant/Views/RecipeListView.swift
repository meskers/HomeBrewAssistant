//
//  RecipeListView.swift
//  HomeBrewAssistant
//
//  Created by Cor Meskers on 10/06/2025.
//
import SwiftUI
import CoreData

struct RecipeListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DetailedRecipeModel.name, ascending: true)],
        animation: .default)
    private var recipes: FetchedResults<DetailedRecipeModel>
    
    @State private var searchText = ""
    @State private var showingAddRecipe = false
    @State private var selectedRecipe: DetailedRecipeModel?
    @State private var showingDetail = false
    @State private var showingFilters = false
    
    // v1.2 Enhanced Filtering
    @State private var selectedCategory: RecipeCategory = .all
    @State private var selectedDifficulty: FilterDifficulty = .all
    @State private var selectedABVRange: ABVRange = .all
    @State private var selectedSortOption: SortOption = .name
    @State private var showingCategoryFilter = false
    
    var filteredRecipes: [DetailedRecipeModel] {
        var filtered = Array(recipes)
        
        // Basic search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { recipe in
                recipe.wrappedName.localizedCaseInsensitiveContains(searchText) ||
                recipe.wrappedType.localizedCaseInsensitiveContains(searchText) ||
                recipe.wrappedNotes.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Category filter
        if selectedCategory != .all {
            filtered = filtered.filter { recipe in
                selectedCategory.matches(recipeType: recipe.wrappedType)
            }
        }
        
        // Difficulty filter (based on ingredient count for now)
        if selectedDifficulty != .all {
            filtered = filtered.filter { recipe in
                let ingredientCount = recipe.ingredientsArray.count
                return selectedDifficulty.matches(ingredientCount: ingredientCount)
            }
        }
        
        // ABV range filter (if ABV data is available)
        if selectedABVRange != .all {
            filtered = filtered.filter { recipe in
                selectedABVRange.matches(abv: recipe.abv)
            }
        }
        
        // Apply sorting
        return filtered.sorted { first, second in
            selectedSortOption.compare(first, second)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Enhanced Header with Stats
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Mijn Recepten")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("\(filteredRecipes.count) van \(recipes.count) recepten")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Quick stats
                        HStack(spacing: 16) {
                            StatBadge(
                                icon: "drop.fill",
                                value: "\(recipes.filter { $0.wrappedType.lowercased().contains("bier") }.count)",
                                label: "Bier",
                                color: .orange
                            )
                            
                            StatBadge(
                                icon: "wineglass.fill",
                                value: "\(recipes.filter { $0.wrappedType.lowercased().contains("wijn") }.count)",
                                label: "Wijn",
                                color: .purple
                            )
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top)
                
                // Enhanced Search & Filter Bar
                VStack(spacing: 12) {
                    // Search Bar
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                    
                    // Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // Category Filter
                            FilterChip(
                                title: selectedCategory.displayName,
                                isSelected: selectedCategory != .all,
                                icon: "tag.circle"
                            ) {
                                showingCategoryFilter = true
                            }
                            
                            // Difficulty Filter
                            FilterChip(
                                title: selectedDifficulty.displayName,
                                isSelected: selectedDifficulty != .all,
                                icon: "star.circle"
                            ) {
                                selectedDifficulty = selectedDifficulty.next()
                            }
                            
                            // ABV Range Filter
                            FilterChip(
                                title: selectedABVRange.displayName,
                                isSelected: selectedABVRange != .all,
                                icon: "percent"
                            ) {
                                selectedABVRange = selectedABVRange.next()
                            }
                            
                            // Sort Option
                            FilterChip(
                                title: selectedSortOption.displayName,
                                isSelected: true,
                                icon: "arrow.up.arrow.down.circle"
                            ) {
                                selectedSortOption = selectedSortOption.next()
                            }
                            
                            // Clear Filters
                            if selectedCategory != .all || selectedDifficulty != .all || selectedABVRange != .all {
                                Button("Clear") {
                                    clearFilters()
                                }
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(6)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 8)
                
                if filteredRecipes.isEmpty {
                    EmptyStateView(
                        hasFilters: selectedCategory != .all || selectedDifficulty != .all || selectedABVRange != .all,
                        onClearFilters: clearFilters
                    )
                } else {
                    List {
                        ForEach(filteredRecipes, id: \.self) { recipe in
                            EnhancedRecipeRowView(recipe: recipe)
                                .onTapGesture {
                                    selectedRecipe = recipe
                                    showingDetail = true
                                }
                        }
                        .onDelete(perform: deleteRecipes)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Recepten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("➕ Nieuw Recept") {
                            showingAddRecipe = true
                        }
                        
                        Button("🎛️ Filters") {
                            showingFilters = true
                        }
                        
                        Divider()
                        
                        Menu("Sorteer op") {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button(action: { selectedSortOption = option }) {
                                    HStack {
                                        Text(option.displayName)
                                        if selectedSortOption == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                RecipeBuilderView()
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipe: recipe)
                    .environment(\.managedObjectContext, viewContext)
            }
            .actionSheet(isPresented: $showingCategoryFilter) {
                ActionSheet(
                    title: Text("Filter op Categorie"),
                    buttons: RecipeCategory.allCases.map { category in
                        .default(Text(category.displayName)) {
                            selectedCategory = category
                        }
                    } + [.cancel()]
                )
            }
        }
    }
    
    private func deleteRecipes(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredRecipes[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting recipe: \(error)")
            }
        }
    }
    
    private func clearFilters() {
        selectedCategory = .all
        selectedDifficulty = .all
        selectedABVRange = .all
        searchText = ""
    }
}

// MARK: - Enhanced Components

struct EnhancedRecipeRowView: View {
    let recipe: DetailedRecipeModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Recipe Type Icon with Background
            ZStack {
                Circle()
                    .fill(categoryColor(for: recipe.wrappedType).opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: iconForRecipeType(recipe.wrappedType))
                    .foregroundColor(categoryColor(for: recipe.wrappedType))
                    .font(.system(size: 18, weight: .medium))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(recipe.wrappedName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // ABV Badge
                    if recipe.abv > 0 {
                        Text("\(String(format: "%.1f", recipe.abv))% ABV")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.brewTheme)
                            .cornerRadius(4)
                    }
                }
                
                HStack {
                    Text(recipe.wrappedType)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("\(recipe.ingredientsArray.count) ingrediënten")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Difficulty indicator
                    DifficultyIndicator(ingredientCount: recipe.ingredientsArray.count)
                }
                
                if !recipe.wrappedNotes.isEmpty {
                    Text(recipe.wrappedNotes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
    
    private func iconForRecipeType(_ type: String) -> String {
        switch type.lowercased() {
        case "beer", "bier":
            return "drop.fill"
        case "wine", "wijn":
            return "wineglass.fill"
        case "cider":
            return "applelogo"
        case "mead", "mede":
            return "honeybee.fill"
        case "kombucha":
            return "leaf.circle.fill"
        default:
            return "flask.fill"
        }
    }
    
    private func categoryColor(for type: String) -> Color {
        switch type.lowercased() {
        case "beer", "bier":
            return .orange
        case "wine", "wijn":
            return .purple
        case "cider":
            return .green
        case "mead", "mede":
            return .yellow
        case "kombucha":
            return .teal
        default:
            return .gray
        }
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                Text(value)
                    .font(.caption)
                    .fontWeight(.bold)
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? Color.brewTheme : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

struct DifficultyIndicator: View {
    let ingredientCount: Int
    
    private var difficulty: (stars: Int, color: Color) {
        switch ingredientCount {
        case 0...3: return (1, .green)
        case 4...6: return (2, .orange)
        case 7...10: return (3, .red)
        default: return (3, .purple)
        }
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < difficulty.stars ? "star.fill" : "star")
                    .foregroundColor(index < difficulty.stars ? difficulty.color : Color(.systemGray4))
                    .font(.caption2)
            }
        }
    }
}

// MARK: - Filter Enums

enum RecipeCategory: String, CaseIterable {
    case all = "Alle"
    case beer = "Bier"
    case wine = "Wijn"
    case cider = "Cider"
    case mead = "Mede"
    case kombucha = "Kombucha"
    case other = "Overig"
    
    var displayName: String { rawValue }
    
    func matches(recipeType: String) -> Bool {
        switch self {
        case .all: return true
        case .beer: return recipeType.lowercased().contains("bier") || recipeType.lowercased().contains("beer")
        case .wine: return recipeType.lowercased().contains("wijn") || recipeType.lowercased().contains("wine")
        case .cider: return recipeType.lowercased().contains("cider")
        case .mead: return recipeType.lowercased().contains("mede") || recipeType.lowercased().contains("mead")
        case .kombucha: return recipeType.lowercased().contains("kombucha")
        case .other: return !["bier", "beer", "wijn", "wine", "cider", "mede", "mead", "kombucha"].contains { recipeType.lowercased().contains($0) }
        }
    }
}

enum FilterDifficulty: String, CaseIterable {
    case all = "Alle"
    case beginner = "Beginner"
    case intermediate = "Gevorderd"
    case advanced = "Expert"
    
    var displayName: String { rawValue }
    
    func matches(ingredientCount: Int) -> Bool {
        switch self {
        case .all: return true
        case .beginner: return ingredientCount <= 3
        case .intermediate: return ingredientCount >= 4 && ingredientCount <= 6
        case .advanced: return ingredientCount > 6
        }
    }
    
    func next() -> FilterDifficulty {
        let cases = FilterDifficulty.allCases
        let currentIndex = cases.firstIndex(of: self) ?? 0
        return cases[(currentIndex + 1) % cases.count]
    }
}

enum ABVRange: String, CaseIterable {
    case all = "Alle ABV"
    case low = "< 4%"
    case moderate = "4-6%"
    case strong = "6-8%"
    case veryStrong = "> 8%"
    
    var displayName: String { rawValue }
    
    func matches(abv: Double) -> Bool {
        switch self {
        case .all: return true
        case .low: return abv < 4.0
        case .moderate: return abv >= 4.0 && abv < 6.0
        case .strong: return abv >= 6.0 && abv < 8.0
        case .veryStrong: return abv >= 8.0
        }
    }
    
    func next() -> ABVRange {
        let cases = ABVRange.allCases
        let currentIndex = cases.firstIndex(of: self) ?? 0
        return cases[(currentIndex + 1) % cases.count]
    }
}

enum SortOption: String, CaseIterable {
    case name = "Naam"
    case dateCreated = "Aangemaakt"
    case dateModified = "Gewijzigd"
    case type = "Type"
    case abv = "ABV"
    case ingredientCount = "Ingrediënten"
    
    var displayName: String { rawValue }
    
    func compare(_ first: DetailedRecipeModel, _ second: DetailedRecipeModel) -> Bool {
        switch self {
        case .name:
            return first.wrappedName < second.wrappedName
        case .dateCreated:
            return (first.createdAt ?? Date.distantPast) > (second.createdAt ?? Date.distantPast)
        case .dateModified:
            return (first.updatedAt ?? Date.distantPast) > (second.updatedAt ?? Date.distantPast)
        case .type:
            return first.wrappedType < second.wrappedType
        case .abv:
            return first.abv > second.abv
        case .ingredientCount:
            return first.ingredientsArray.count > second.ingredientsArray.count
        }
    }
    
    func next() -> SortOption {
        let cases = SortOption.allCases
        let currentIndex = cases.firstIndex(of: self) ?? 0
        return cases[(currentIndex + 1) % cases.count]
    }
}

// MARK: - Updated Empty State

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Zoek recepten...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct EmptyStateView: View {
    let hasFilters: Bool
    let onClearFilters: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: hasFilters ? "line.3.horizontal.decrease.circle" : "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(hasFilters ? "Geen recepten gevonden" : "Nog geen recepten")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(hasFilters ? "Probeer andere filters" : "Voeg je eerste recept toe om te beginnen")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if hasFilters {
                Button("Wis Filters") {
                    onClearFilters()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    RecipeListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
