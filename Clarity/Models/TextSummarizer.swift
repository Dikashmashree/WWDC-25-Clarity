class TextSummarizer {
    static func summarize(_ text: String) -> String {
        // Break into sentences
        let sentences = text.components(separatedBy: ". ")
        
        // Find key sentences based on important words
        let keyPoints = sentences.filter { sentence in
            containsImportantWords(sentence)
        }
        
        return keyPoints.joined(separator: ". ")
    }
} 