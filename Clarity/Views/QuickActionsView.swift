struct QuickActionsView: View {
    let text: String
    
    var body: some View {
        VStack {
            if let amount = extractAmount(from: text) {
                QuickActionButton("Add to Calculator", systemImage: "plus.circle") {
                    // Add to calculator
                }
            }
            
            if let date = extractDate(from: text) {
                QuickActionButton("Add to Calendar", systemImage: "calendar") {
                    // Add calendar event
                }
            }
            
            if containsAddress(text) {
                QuickActionButton("Show on Map", systemImage: "map") {
                    // Show offline map
                }
            }
        }
    }
} 