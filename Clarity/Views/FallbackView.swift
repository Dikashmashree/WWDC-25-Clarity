
import SwiftUI

struct FallbackView: View {
    @Binding var showImagePicker: Bool
    @Binding var selectedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Camera Not Available")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Please select an image from your photo library")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: {
                showImagePicker = true
            }) {
                Text("Select Image")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
} 