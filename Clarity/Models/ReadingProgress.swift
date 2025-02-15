struct ReadingProgress: Codable {
    let documentId: UUID
    var lastPosition: Int
    var lastReadDate: Date
    var completionPercentage: Double
    
    static func save(_ position: Int, for documentId: UUID) {
        // Save reading position for resume later
    }
} 