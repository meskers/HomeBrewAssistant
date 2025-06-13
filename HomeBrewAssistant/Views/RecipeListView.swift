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
    
    var filteredRecipes: [DetailedRecipeModel] {
        if searchText.isEmpty {
            return Array(recipes)
        } else {
            return recipes.filter { recipe in
                recipe.wrappedName.localizedCaseInsensitiveContains(searchText) ||
                recipe.wrappedType.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                if filteredRecipes.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(filteredRecipes, id: \.self) { recipe in
                            RecipeRowView(recipe: recipe)
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
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddRecipe = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
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
        }
    }
    
    private func deleteRecipes(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredRecipes[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Handle error appropriately
                print("Error deleting recipe: \(error)")
            }
        }
    }
}

struct RecipeRowView: View {
    let recipe: DetailedRecipeModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Recipe Type Icon
            Image(systemName: iconForRecipeType(recipe.wrappedType))
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.wrappedName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(recipe.wrappedType)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !recipe.wrappedNotes.isEmpty {
                    Text(recipe.wrappedNotes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(recipe.ingredientsArray.count) ingrediënten")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let createdAt = recipe.createdAt {
                    Text(createdAt, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
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
        case "mead":
            return "honeybee.fill"
        default:
            return "flask.fill"
        }
    }
}

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
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Geen recepten gevonden")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Voeg je eerste recept toe om te beginnen")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
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
