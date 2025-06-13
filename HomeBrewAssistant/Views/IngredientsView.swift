//
//  IngredientsView.swift
//  HomeBrewAssistant
//
//  Created by Cor Meskers on 09/06/2025.
//

import SwiftUI

struct IngredientsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Ingredient.name, ascending: true)],
        animation: .default)
    private var ingredients: FetchedResults<Ingredient>
    
    @State private var showingAddIngredient = false
    @State private var searchText = ""
    @State private var selectedType: IngredientType?
    
    var filteredIngredients: [Ingredient] {
        ingredients.filter { ingredient in
            let matchesSearch = searchText.isEmpty || 
                ingredient.wrappedName.localizedCaseInsensitiveContains(searchText)
            let matchesType = selectedType == nil || 
                ingredient.wrappedType == selectedType?.rawValue
            return matchesSearch && matchesType
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredIngredients) { ingredient in
                    IngredientRow(ingredient: ingredient)
                }
                .onDelete(perform: deleteIngredients)
            }
            .searchable(text: $searchText, prompt: "Search ingredients")
            .navigationTitle("Ingredients")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(IngredientType.allCases, id: \.self) { type in
                            Button {
                                selectedType = type
                            } label: {
                                Label(type.rawValue, systemImage: type.icon)
                            }
                        }
                        
                        Button("All Types") {
                            selectedType = nil
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddIngredient = true
                    } label: {
                        Label("Add Ingredient", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddIngredient) {
                AddIngredientView()
            }
        }
    }
    
    private func deleteIngredients(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredIngredients[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct IngredientRow: View {
    let ingredient: Ingredient
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(ingredient.wrappedName)
                .font(.headline)
            
            HStack {
                Label(ingredient.wrappedType, systemImage: typeIcon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(ingredient.wrappedAmount)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var typeIcon: String {
        switch ingredient.wrappedType {
        case "Grain": return "leaf.fill"
        case "Hop": return "flower.fill"
        case "Yeast": return "bubble.left.fill"
        case "Adjunct": return "plus.circle.fill"
        default: return "questionmark.circle.fill"
        }
    }
}

struct AddIngredientView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var type = IngredientType.grain
    @State private var amount = ""
    @State private var timing = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ingredient Details")) {
                    TextField("Name", text: $name)
                    
                    Picker("Type", selection: $type) {
                        ForEach(IngredientType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    TextField("Timing", text: $timing)
                }
            }
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveIngredient()
                    }
                    .disabled(name.isEmpty || amount.isEmpty)
                }
            }
        }
    }
    
    private func saveIngredient() {
        withAnimation {
            let newIngredient = Ingredient(context: viewContext)
            newIngredient.id = UUID()
            newIngredient.name = name
            newIngredient.type = type.rawValue
            newIngredient.amount = amount
            newIngredient.timing = timing
            
            do {
                try viewContext.save()
                dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    IngredientsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

