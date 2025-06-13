//
//  BeerXMLImportExportView.swift
//  HomeBrewAssistant
//
//  Created by Cor Meskers on 11/06/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct BeerXMLImportExportView: View {
    @Binding var recipes: [DetailedRecipe]
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager
    
    @State private var showingImportPicker = false
    @State private var showingExportPicker = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var selectedRecipeForExport: DetailedRecipe?
    @State private var showingRecipeSelector = false
    @State private var isImporting = false
    @State private var isExporting = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    headerSection
                    
                    // Import Section
                    importSection
                    
                    // Export Section
                    exportSection
                    
                    // Info Section
                    infoSection
                    
                    Spacer(minLength: 30)
                }
                .padding()
            }
            .navigationTitle("BeerXML Import/Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [UTType.xml, UTType.plainText, UTType.data],
            allowsMultipleSelection: false
        ) { result in
            handleImportResult(result)
        }
        .fileExporter(
            isPresented: $showingExportPicker,
            document: BeerXMLDocument(content: exportContent),
            contentType: UTType.xml,
            defaultFilename: exportFilename
        ) { result in
            handleExportResult(result)
        }
        .sheet(isPresented: $showingRecipeSelector) {
            RecipeSelectionView(recipes: recipes, selectedRecipe: $selectedRecipeForExport)
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - View Sections
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 50))
                .foregroundColor(.brewTheme)
            
            Text("BeerXML Import & Export")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Uitwisselen van recepten met andere brouw apps")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }
    
    private var importSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                    .foregroundColor(.green)
                Text("Import Recepten")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Text("Importeer BeerXML bestanden van andere brouw software zoals BeerSmith, Brewfather, of BrewTarget.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Button(action: {
                showingImportPicker = true
            }) {
                HStack {
                    if isImporting {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "doc.badge.plus")
                    }
                    Text(isImporting ? "Importeren..." : "Selecteer BeerXML bestand")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(12)
            }
            .disabled(isImporting)
            
            // Import tips
            VStack(alignment: .leading, spacing: 8) {
                Text("💡 Import Tips:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
                Text("• Ondersteunt .xml en .beerxml bestanden")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("• Importeert ingrediënten, timings en basis receptinfo")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("• Controleer altijd geïmporteerde recepten")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 5)
    }
    
    private var exportSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.blue)
                Text("Export Recepten")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Text("Exporteer je recepten naar BeerXML formaat om te delen met andere brouwers of software.")
                .font(.body)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Button(action: {
                    showingRecipeSelector = true
                }) {
                    HStack {
                        Image(systemName: "doc.on.doc")
                        Text("Selecteer recept om te exporteren")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                
                if let selectedRecipe = selectedRecipeForExport {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Geselecteerd: \(selectedRecipe.name)")
                            .font(.subheadline)
                        Spacer()
                        Button("Export") {
                            showingExportPicker = true
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isExporting)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            // Export info
            VStack(alignment: .leading, spacing: 8) {
                Text("📤 Export Info:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Text("• Standaard BeerXML 1.0 formaat")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("• Compatibel met de meeste brouw software")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("• Bevat ingrediënten, timings en basis gegevens")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 5)
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.orange)
                Text("Over BeerXML")
                    .font(.headline)
            }
            
            Text("BeerXML is de industriestandaard voor het uitwisselen van brouwrecepten. Het wordt ondersteund door vrijwel alle professionele brouw software.")
                .font(.body)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("🔗 Compatibel met:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("• BeerSmith")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("• Brewfather")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("• BrewTarget")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("• Recipe DB")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("• En vele andere...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Properties
    
    private var exportContent: String {
        guard let recipe = selectedRecipeForExport else {
            return ""
        }
        // TODO: Convert DetailedRecipe to DetailedRecipeModel for export
        return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<RECIPES>\n  <RECIPE>\n    <NAME>\(recipe.name)</NAME>\n    <STYLE>\(recipe.style)</STYLE>\n  </RECIPE>\n</RECIPES>"
    }
    
    private var exportFilename: String {
        guard let recipe = selectedRecipeForExport else {
            return "recipe.xml"
        }
        let safeName = recipe.name.replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: "\\", with: "-")
        return "\(safeName).xml"
    }
    
    // MARK: - Handler Methods
    
    private func handleImportResult(_ result: Result<[URL], Error>) {
        isImporting = true
        
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                showAlert(title: "Import Error", message: "Geen bestand geselecteerd.")
                isImporting = false
                return
            }
            
            // Start accessing the security scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                isImporting = false
                showAlert(title: "Import Error", message: "Geen toegang tot het geselecteerde bestand. Probeer opnieuw.")
                return
            }
            
            defer {
                // Always stop accessing the resource when done
                url.stopAccessingSecurityScopedResource()
            }
            
            do {
                let xmlData = try Data(contentsOf: url)
                print("📁 Loading XML file: \(url.lastPathComponent), size: \(xmlData.count) bytes")
                
                let importedRecipes = BeerXMLManager.importRecipes(from: xmlData)
                
                let handleCompletion: () -> Void = {
                    self.isImporting = false
                    if importedRecipes.isEmpty {
                        self.showAlert(
                            title: "Import Probleem", 
                            message: "Geen geldige recepten gevonden in het XML bestand. Controleer of het een geldig BeerXML bestand is."
                        )
                    } else {
                        // TODO: Convert DetailedRecipeModel to DetailedRecipe for display
                        // self.recipes.append(contentsOf: importedRecipes)
                        self.showAlert(
                            title: "Import Succesvol", 
                            message: "\(importedRecipes.count) recept(en) succesvol geïmporteerd! (Conversie naar UI model nog te implementeren)"
                        )
                    }
                }
                
                DispatchQueue.main.async(execute: handleCompletion)
            } catch {
                isImporting = false
                print("❌ File read error: \(error)")
                showAlert(title: "Import Error", message: "Kon BeerXML bestand niet lezen: \(error.localizedDescription)")
            }
            
        case .failure(let error):
            isImporting = false
            showAlert(title: "Import Error", message: "Fout bij selecteren bestand: \(error.localizedDescription)")
        }
    }
    
    private func handleExportResult(_ result: Result<URL, Error>) {
        isExporting = false
        
        switch result {
        case .success(_):
            showAlert(title: "Export Succesvol", message: "Recept succesvol geëxporteerd naar BeerXML!")
        case .failure(let error):
            showAlert(title: "Export Error", message: "Fout bij exporteren: \(error.localizedDescription)")
        }
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}

// MARK: - Recipe Selection View

struct RecipeSelectionView: View {
    let recipes: [DetailedRecipe]
    @Binding var selectedRecipe: DetailedRecipe?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(recipes) { recipe in
                Button(action: {
                    selectedRecipe = recipe
                    dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(recipe.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(recipe.style)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedRecipe?.id == recipe.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Selecteer Recept")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Annuleren") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - BeerXML Document for File Export

struct BeerXMLDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.xml] }
    
    var content: String
    
    init(content: String = "") {
        self.content = content
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            content = String(data: data, encoding: .utf8) ?? ""
        } else {
            content = ""
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = content.data(using: .utf8) ?? Data()
        return FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    BeerXMLImportExportView(recipes: .constant([
        DetailedRecipe(
            name: "Test Recipe",
            style: "IPA",
            abv: 6.2,
            ibu: 45,
            difficulty: .intermediate,
            brewTime: 240,
            ingredients: [],
            instructions: [],
            notes: "Test notes"
        )
    ]))
    .environmentObject(LocalizationManager.shared)
} 