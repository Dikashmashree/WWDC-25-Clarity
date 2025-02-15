import SwiftUI
import VisionKit

struct ScannerView: UIViewControllerRepresentable {
    @ObservedObject var scannerManager: ScannerManager
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .balanced,
            isHighlightingEnabled: true
        )
        scanner.delegate = scannerManager
        scannerManager.setDataScanner(scanner)
        try? scanner.startScanning()
        return scanner
    }
   
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}
}

struct SmartScanZone: View {
    @State private var isDetectingText = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
            .strokeBorder(
                .linearGradient(
                    colors: [
                        isDetectingText ? AppTheme.accent : .white.opacity(0.6),
                        isDetectingText ? AppTheme.accent.opacity(0.4) : .white.opacity(0.3)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                style: StrokeStyle(lineWidth: 3, dash: [10, 10])
            )
            .animation(.easeInOut(duration: 0.3), value: isDetectingText)
            .onChange(of: isDetectingText) { newValue in
                if newValue {
                    HapticManager.shared.selectionFeedback()
                    // Play subtle sound effect
                    AudioServicesPlaySystemSound(1519)
                }
            }
    }
} 
