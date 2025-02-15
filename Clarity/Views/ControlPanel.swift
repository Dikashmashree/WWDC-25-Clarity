
import SwiftUI

struct ControlPanel: View {
    @ObservedObject var scannerManager: ScannerManager
    @State private var showSettings = false
    @State private var isCapturing = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            //scanning indicator
            if scannerManager.isScanning {
                Text("Scanning text...")
                    .font(.headline)
                    .foregroundColor(AppTheme.text)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        Capsule()
                            .fill(AppTheme.secondaryBackground)
                            .opacity(0.8)
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            //control buttons
            HStack(spacing: 32) {
                //flash button
                if scannerManager.isTorchAvailable {
                    ControlButton(
                        icon: scannerManager.flashEnabled ? "bolt.fill" : "bolt.slash.fill",
                        isActive: scannerManager.flashEnabled,
                        action: { scannerManager.toggleFlash() }
                    )
                }
                
                //capture button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isCapturing = true
                        scannerManager.captureText()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isCapturing = false
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.ButtonStyle.primaryBackground)
                            .frame(width: 84, height: 84)
                            .shadow(color: AppTheme.ButtonStyle.shadow.opacity(0.3),
                                    radius: 8, x: 0, y: 4)
                        
                        Circle()
                            .stroke(AppTheme.accent, lineWidth: 3)
                            .frame(width: 70, height: 70)
                        
                        if isCapturing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.accent))
                        }
                    }
                    .scaleEffect(isCapturing ? 0.9 : 1.0)
                }
                .buttonStyle(ScaleButtonStyle())
                .disabled(isCapturing)
                
                //settings button
                ControlButton(
                    icon: "gearshape.fill",
                    action: { showSettings = true }
                )
            }
        }
        .padding(.bottom, 40)
        .padding(.horizontal, 20)
        .animation(.easeInOut, value: scannerManager.isScanning)
        .sheet(isPresented: $showSettings) {
            SettingsView(scannerManager: scannerManager)
        }
    }
}

struct ControlButton: View {
    let icon: String
    var isActive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(isActive ? AppTheme.accent : AppTheme.text)
                .frame(width: AppTheme.buttonSize, height: AppTheme.buttonSize)
                .background(
                    Circle()
                        .fill(AppTheme.ButtonStyle.secondaryBackground)
                        .shadow(color: AppTheme.ButtonStyle.shadow.opacity(0.2),
                                radius: 6, x: 0, y: 3)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
} 