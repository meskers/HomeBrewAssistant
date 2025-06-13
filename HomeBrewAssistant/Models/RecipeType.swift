import SwiftUI

enum RecipeType: String, CaseIterable {
    case beer = "Bier"
    case cider = "Cider"
    case wine = "Wijn"
    case kombucha = "Kombucha"
    case mead = "Mede"
    case other = "Anders"
    
    var icon: String {
        switch self {
        case .beer: return "mug"
        case .cider: return "applelogo"
        case .wine: return "wineglass"
        case .kombucha: return "leaf"
        case .mead: return "drop"
        case .other: return "questionmark"
        }
    }
    
    var color: Color {
        switch self {
        case .beer: return .orange
        case .cider: return .green
        case .wine: return .purple
        case .kombucha: return .teal
        case .mead: return .yellow
        case .other: return .gray
        }
    }
}
