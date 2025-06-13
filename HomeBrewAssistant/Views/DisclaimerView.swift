import SwiftUI

struct DisclaimerView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Disclaimer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    Group {
                        Text("HomeBrewAssistant is designed to help you with your home brewing journey. However, please note the following:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            DisclaimerItem(
                                icon: "exclamationmark.triangle.fill",
                                title: "Safety First",
                                description: "Always follow proper brewing safety guidelines and local regulations."
                            )
                            
                            DisclaimerItem(
                                icon: "checkmark.shield.fill",
                                title: "Quality Control",
                                description: "While we provide tools and calculations, final quality control is your responsibility."
                            )
                            
                            DisclaimerItem(
                                icon: "info.circle.fill",
                                title: "Accuracy",
                                description: "Calculations and recommendations are based on standard brewing practices but may need adjustment for your specific setup."
                            )
                            
                            DisclaimerItem(
                                icon: "hand.raised.fill",
                                title: "Legal Compliance",
                                description: "Ensure you comply with all local laws and regulations regarding home brewing."
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
                    Button("Done") {
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