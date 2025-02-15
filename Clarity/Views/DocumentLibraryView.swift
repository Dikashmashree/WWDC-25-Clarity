import SwiftUI

struct DocumentLibraryView: View {
    @State private var searchText = ""
    @State private var selectedCategory: ScannedDocument.Category?
    @State private var sortOrder: SortOrder = .dateDescending
    
    var filteredDocuments: [ScannedDocument] {
        documents
            .filter { doc in
                if let category = selectedCategory {
                    return doc.category == category
                }
                return true
            }
            .filter { doc in
                if searchText.isEmpty { return true }
                return doc.text.localizedCaseInsensitiveContains(searchText) ||
                       doc.title.localizedCaseInsensitiveContains(searchText)
            }
            .sorted { /* sorting logic */ }
    }
    
    var body: some View {
        List {
            ForEach(filteredDocuments) { document in
                DocumentRow(document: document)
            }
        }
        .searchable(text: $searchText)
    }
} 