import SwiftUI

struct DisclaimerView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("disclaimer.title".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    Group {
                        Text("disclaimer.introduction".localized)
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            DisclaimerItem(
                                icon: "exclamationmark.triangle.fill",
                                title: "disclaimer.safety.title".localized,
                                description: "disclaimer.safety.description".localized
                            )
                            
                            DisclaimerItem(
                                icon: "checkmark.shield.fill",
                                title: "disclaimer.quality.title".localized,
                                description: "disclaimer.quality.description".localized
                            )
                            
                            DisclaimerItem(
                                icon: "info.circle.fill",
                                title: "disclaimer.accuracy.title".localized,
                                description: "disclaimer.accuracy.description".localized
                            )
                            
                            DisclaimerItem(
                                icon: "hand.raised.fill",
                                title: "disclaimer.legal.title".localized,
                                description: "disclaimer.legal.description".localized
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("action.done".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DisclaimerItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    DisclaimerView()
} 