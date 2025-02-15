struct TextRule: Identifiable, Codable {
    let id: UUID
    var pattern: String
    var replacement: String
    var isEnabled: Bool
}

struct TextRulesView: View {
    @State private var rules: [TextRule] = []
    
    var body: some View {
        List {
            ForEach(rules) { rule in
                RuleRow(rule: rule)
            }
            .onDelete(perform: deleteRule)
        }
    }
} 