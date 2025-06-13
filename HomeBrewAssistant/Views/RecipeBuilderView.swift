import SwiftUI
import CoreData
import Foundation

struct RecipeBuilderView: View {
    var recipeToEdit: DetailedRecipeModel?

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RecipeViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    init(recipeToEdit: DetailedRecipeModel? = nil) {
        self.recipeToEdit = recipeToEdit
        self._viewModel = StateObject(wrappedValue: RecipeViewModel(recipeToEdit: recipeToEdit))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    recipeTypeSection
                    saveButtonSection
                }
                .padding()
            }
            .navigationTitle("Recept")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuleren") {
                        dismiss()
                    }
                }
            }
            .alert("Status", isPresented: $showAlert) {
                Button("OK") {
                    if !viewModel.recipeName.isEmpty {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Receptdetails")
                .font(.headline)
            
            TextField("Receptnaam", text: $viewModel.recipeName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private var recipeTypeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Brouwtype")
                .font(.headline)
            
            Picker("Type", selection: $viewModel.selectedType) {
                Text("Bier").tag(RecipeType.beer)
                Text("Cider").tag(RecipeType.cider)
                Text("Wijn").tag(RecipeType.wine)
                Text("Kombucha").tag(RecipeType.kombucha)
                Text("Mede").tag(RecipeType.mead)
                Text("Anders").tag(RecipeType.other)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private var saveButtonSection: some View {
        Button("Recept Opslaan") {
            do {
                try viewModel.saveRecipe(context: viewContext)
                showAlert = true
                alertMessage = "Recept opgeslagen!"
            } catch {
                showAlert = true
                alertMessage = "Fout bij opslaan: \(error.localizedDescription)"
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
}

#Preview {
    RecipeBuilderView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

   
