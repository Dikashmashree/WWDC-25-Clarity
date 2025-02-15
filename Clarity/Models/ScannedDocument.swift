struct ScannedDocument: Codable, Identifiable {
    let id: UUID
    var title: String
    var text: String
    var date: Date
    var category: Category
    var tags: [String]
    var isFavorite: Bool
    
    enum Category: String, Codable {
        case receipt
        case document
        case book
        case note
        case label
        case other
    }
}

class DocumentManager: ObservableObject {
    @Published var documents: [ScannedDocument] = []
    
    func saveDocument(_ text: String, title: String, category: ScannedDocument.Category) {
        let document = ScannedDocument(
            id: UUID(),
            title: title,
            text: text,
            date: Date(),
            category: category,
            tags: [],
            isFavorite: false
        )
        documents.append(document)
        saveToStorage()
    }
} 