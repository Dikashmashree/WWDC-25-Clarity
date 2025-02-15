import SwiftUI
import VisionKit

struct MainView: View {
    @StateObject private var scannerManager = ScannerManager()
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showPhotoPermissionAlert = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ZStack {
                //camera view or fallback
                if scannerManager.isCameraAvailable {
                    ScannerContainerView(scannerManager: scannerManager)
                } else {
                    FallbackView(showImagePicker: $showImagePicker, selectedImage: $selectedImage)
                }
                
                //overlay controls
                VStack {
                    Spacer()
                    ControlPanel(scannerManager: scannerManager)
                }
            }
            
            .sheet(isPresented: $scannerManager.showTextSheet) {
                TextDetailView(
                    text: scannerManager.recognizedText,
                    scannerManager: scannerManager
                )
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage, 
                       showPermissionAlert: $showPhotoPermissionAlert)
        }
        .alert("Camera Access Required", isPresented: $scannerManager.showPermissionAlert) {
            Button("Open Settings", role: .none) {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable camera access in Settings to use text scanning features.")
        }
        .alert("Photo Library Access Required", isPresented: $showPhotoPermissionAlert) {
            Button("Open Settings", role: .none) {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable photo library access in Settings to select images.")
        }
        .preferredColorScheme(nil)
    }
} 
