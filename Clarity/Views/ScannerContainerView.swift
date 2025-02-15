
import SwiftUI
import VisionKit

struct ScannerContainerView: View {
    @ObservedObject var scannerManager: ScannerManager
    
    var body: some View {
        ZStack {
            ScannerView(scannerManager: scannerManager)
                .ignoresSafeArea()
            CameraOverlayView()
                .ignoresSafeArea()
        }
    }
}
#Preview {
    ScannerContainerView(scannerManager: ScannerManager())
} 