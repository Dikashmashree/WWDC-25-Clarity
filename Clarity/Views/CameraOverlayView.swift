import SwiftUI

struct CameraOverlayView: View {
    @ObservedObject var scannerManager: ScannerManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                //scanning frame
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .strokeBorder(
                        .linearGradient(
                            colors: [
                                AppTheme.accent.opacity(0.8),
                                AppTheme.accent.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(
                            lineWidth: 2,
                            dash: [8, 8]
                        )
                    )
                    .padding(40)
                
                //scanning quality indicator
                VStack {
                    Text("Scanning Quality: \(scanningQualityText)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .fill(AppTheme.overlay)
                                .opacity(0.8)
                        )
                    Spacer()
                }
                .padding(.top, 20)
            }
        }
    }
    
    private var scanningQualityText: String {
        if scannerManager.lightLevel < 0.3 {
            return "Low Light - Move Closer"
        } else if scannerManager.isBlurry {
            return "Blurry - Hold Steady"
        }
        return "Good"
    }
}

struct CornerGuide: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 20))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 20, y: 0))
        }
        .stroke(Color.white, lineWidth: 3)
        .frame(width: 20, height: 20)
    }
} 