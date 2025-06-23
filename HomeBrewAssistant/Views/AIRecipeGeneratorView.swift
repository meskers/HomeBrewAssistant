import SwiftUI

struct AIRecipeGeneratorView: View {
    @StateObject private var aiGenerator = AIRecipeGenerator()
    @StateObject private var localizationManager = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode
    @Binding var recipes: [DetailedRecipe]
    
    @State private var selectedStyle: BJCPStyle?
    @State private var selectedComplexity: RecipeComplexity = .intermediate
    @State private var batchSize: Double = 20.0
    @State private var showingStylePicker = false
    @State private var showingPreferences = false
    @State private var searchText = ""
    @State private var showingRecipeDetail = false
    
    private let bjcpDatabase = BJCPDatabase()
    
    @State private var errorMessage: String = ""
    @State private var showingError: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    
                    if aiGenerator.isGenerating {
                        generationProgressSection
                    } else {
                        configurationSection
                    }
                    
                    if let recipe = aiGenerator.generatedRecipe {
                        generatedRecipeSection(recipe)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("🤖 AI Recipe Generator")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localizationManager.localized("action.cancel")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.brewTheme)
                }
            }
            .sheet(isPresented: $showingStylePicker) {
                StyleSelectionView(selectedStyle: $selectedStyle)
            }
            .sheet(isPresented: $showingRecipeDetail) {
                if let recipe = aiGenerator.generatedRecipe {
                    DetailedRecipeView(recipe: recipe)
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // AI Brain Animation
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                    .scaleEffect(aiGenerator.isGenerating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: aiGenerator.isGenerating)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(aiGenerator.isGenerating ? 360 : 0))
                    .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: aiGenerator.isGenerating)
            }
            
            VStack(spacing: 8) {
                Text("ai.recipe.title".localized)
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                Text("ai.recipe.subtitle".localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    // MARK: - Generation Progress Section
    private var generationProgressSection: some View {
        VStack(spacing: 20) {
            Text("🧠 Brewing the Perfect Recipe...")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                ProgressView(value: aiGenerator.generationProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .brewTheme))
                    .scaleEffect(y: 2.0)
                
                Text("\(Int(aiGenerator.generationProgress * 100))% Complete")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Generation Steps
            VStack(alignment: .leading, spacing: 8) {
                generationStep("📊 Calculating specifications", isActive: aiGenerator.generationProgress > 0.0)
                generationStep("🌾 Selecting grain bill", isActive: aiGenerator.generationProgress > 0.2)
                generationStep("🌿 Calculating hop schedule", isActive: aiGenerator.generationProgress > 0.4)
                generationStep("🦠 Choosing yeast strain", isActive: aiGenerator.generationProgress > 0.6)
                generationStep("⚗️ Optimizing recipe", isActive: aiGenerator.generationProgress > 0.8)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private func generationStep(_ text: String, isActive: Bool) -> some View {
        HStack {
            Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isActive ? .green : .gray)
            
            Text(text)
                .foregroundColor(isActive ? .primary : .secondary)
            
            Spacer()
        }
    }
    
    // MARK: - Configuration Section
    private var configurationSection: some View {
        VStack(spacing: 24) {
            // Style Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("🍺 Beer Style")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Button(action: { showingStylePicker = true }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(selectedStyle?.name ?? "Select a Style")
                                .font(.body.weight(.medium))
                                .foregroundColor(selectedStyle == nil ? .secondary : .primary)
                            
                            if let style = selectedStyle {
                                Text(style.category)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.brewTheme)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            
            // Complexity Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("⚗️ Recipe Complexity")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Picker("Complexity", selection: $selectedComplexity) {
                    ForEach(RecipeComplexity.allCases, id: \.self) { complexity in
                        Text(complexityDescription(complexity))
                            .tag(complexity)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // Batch Size
            VStack(alignment: .leading, spacing: 12) {
                Text("🪣 Batch Size")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Slider(value: $batchSize, in: 5...40, step: 1) {
                        Text("Batch Size")
                    }
                    .accentColor(.brewTheme)
                    
                    Text("\(Int(batchSize))L")
                        .font(.body.weight(.medium))
                        .foregroundColor(.brewTheme)
                        .frame(width: 50)
                }
            }
            
            // Generate Button
            Button(action: generateRecipe) {
                HStack {
                    Image(systemName: "brain.head.profile")
                    Text("Generate AI Recipe")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(selectedStyle == nil)
            .opacity(selectedStyle == nil ? 0.6 : 1.0)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Generated Recipe Section
    private func generatedRecipeSection(_ recipe: DetailedRecipe) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🎉 Generated Recipe")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                Spacer()
                
                                        Button("Save Recipe") {
                            addToRecipes(recipe)
                        }
                .font(.body.weight(.medium))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.brewTheme)
                .cornerRadius(8)
            }
            
            // Recipe Preview
            VStack(spacing: 12) {
                recipeStatRow("🍺 Style", recipe.style)
                recipeStatRow("🎯 ABV", "\(String(format: "%.1f", recipe.abv))%")
                recipeStatRow("🌿 IBU", "\(recipe.ibu)")
                recipeStatRow("⏱️ Brew Time", "\(recipe.brewTime) min")
                recipeStatRow("🎓 Difficulty", recipe.difficulty.rawValue)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Quick Actions
            HStack {
                Button("View Details") {
                    showingRecipeDetail = true
                }
                .font(.body.weight(.medium))
                .foregroundColor(.brewTheme)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.brewTheme.opacity(0.1))
                .cornerRadius(8)
                
                Button("Generate Another") {
                    generateRecipe()
                }
                .font(.body.weight(.medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(.brewTheme)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // Add function to save recipe to DetailedRecipe list
    private func addToRecipes(_ recipe: DetailedRecipe) {
        recipes.append(recipe)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func recipeStatRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body.weight(.medium))
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Helper Functions
    private func complexityDescription(_ complexity: RecipeComplexity) -> String {
        switch complexity {
        case .beginner:
            return "Beginner (2-3 ingredients)"
        case .intermediate:
            return "Intermediate (3-5 ingredients)"
        case .advanced:
            return "Advanced (4-6 ingredients)"
        case .expert:
            return "Expert (5+ ingredients)"
        }
    }
    
    private func generateRecipe() {
        guard let style = selectedStyle else { return }
        
        // Show loading state
        withAnimation {
            aiGenerator.isGenerating = true
            aiGenerator.generationProgress = 0.0
        }
        
        Task {
            do {
                // Add timeout to recipe generation
                try await withTaskTimeout(seconds: 30) {
                    await aiGenerator.generateRecipe(
                        for: style,
                        complexity: selectedComplexity,
                        batchSize: batchSize
                    )
                }
            } catch is CancellationError {
                await MainActor.run {
                    // Show timeout error
                    showError("Het genereren van het recept duurde te lang. Probeer het opnieuw met een eenvoudiger recept.")
                    aiGenerator.isGenerating = false
                }
            } catch {
                await MainActor.run {
                    // Show general error
                    showError("Er is een fout opgetreden: \(error.localizedDescription)")
                    aiGenerator.isGenerating = false
                }
            }
        }
    }
    
    private func withTaskTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            // Add the main operation
            group.addTask {
                try await operation()
            }
            
            // Add the timeout task
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw CancellationError()
            }
            
            // Return the first result and cancel the rest
            defer { group.cancelAll() }
            return try await group.next()!
        }
    }
    
    private func showError(_ message: String) {
        // Show error alert
        errorMessage = message
        showingError = true
    }
}

// MARK: - Style Selection View
struct StyleSelectionView: View {
    @Binding var selectedStyle: BJCPStyle?
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    
    private let bjcpDatabase = BJCPDatabase()
    
    private var filteredStyles: [BJCPStyle] {
        if searchText.isEmpty {
            return bjcpDatabase.allStyles
        } else {
            return bjcpDatabase.searchStyles(query: searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("🔍 Popular Styles") {
                    ForEach(bjcpDatabase.beginnerFriendlyStyles, id: \.id) { style in
                        StyleRow(style: style) {
                            selectedStyle = style
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                
                Section("🧪 Intermediate Styles") {
                    ForEach(bjcpDatabase.intermediateStyles, id: \.id) { style in
                        StyleRow(style: style) {
                            selectedStyle = style
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                
                Section("⚗️ Advanced Styles") {
                    ForEach(bjcpDatabase.advancedStyles, id: \.id) { style in
                        StyleRow(style: style) {
                            selectedStyle = style
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Select Beer Style")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search beer styles...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct StyleRow: View {
    let style: BJCPStyle
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(style.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(style.id)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.brewTheme)
                        .cornerRadius(6)
                }
                
                Text(style.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(style.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    complexityBadge(style.complexity)
                    
                    Spacer()
                    
                    Text("ABV: \(String(format: "%.1f", style.abvRange.lowerBound))-\(String(format: "%.1f", style.abvRange.upperBound))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func complexityBadge(_ complexity: RecipeComplexity) -> some View {
        Text(complexity.rawValue)
            .font(.caption.weight(.medium))
            .foregroundColor(complexityColor(complexity))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(complexityColor(complexity).opacity(0.2))
            .cornerRadius(6)
    }
    
    private func complexityColor(_ complexity: RecipeComplexity) -> Color {
        switch complexity {
        case .beginner:
            return .green
        case .intermediate:
            return .orange
        case .advanced:
            return .red
        case .expert:
            return .purple
        }
    }
}

// MARK: - Preview
struct AIRecipeGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        AIRecipeGeneratorView(recipes: .constant([]))
    }
} 