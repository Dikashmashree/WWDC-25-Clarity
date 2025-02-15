import SwiftUI
import VisionKit
import AVFoundation
import Vision

class ScannerManager: NSObject, ObservableObject, DataScannerViewControllerDelegate, AVSpeechSynthesizerDelegate {
    @Published var recognizedText = ""
    @Published var showTextSheet = false
    @Published var isCameraAvailable = false
    @Published var flashEnabled = false
    @Published var defaultTextSize: CGFloat = 16
    @Published var defaultVoice = "en-US"
    @Published var showPermissionAlert = false
    @Published var isScanning = false
    @Published var autoFlashEnabled = false
    @Published var showGuidelines = true
    @Published var isTorchAvailable = false
    @Published var isBoldText: Bool = false
    @Published var voiceGuidanceEnabled = false
    @Published var isGuiding = false
    @Published var currentWordRange: Range<String.Index>?
    @Published var isPlaying: Bool = false
    @Published var isPaused: Bool = false
    @Published var playbackProgress: Double = 0
    
    private let synthesizer = AVSpeechSynthesizer()
    private var dataScannerViewController: DataScannerViewController?
    
    override init() {
        super.init()
        checkCameraAvailability()
    }
    
    func checkCameraAvailability() {
        //1st check if the device supports scanning
        guard DataScannerViewController.isSupported else {
            isCameraAvailable = false
            return
        }
        
        // Checking for camera permission status
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraAvailable = DataScannerViewController.isAvailable
            
            if let device = AVCaptureDevice.default(for: .video) {
                isTorchAvailable = device.hasTorch
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isCameraAvailable = granted && DataScannerViewController.isAvailable
                    //check if torch availability after permission granted
                    if let device = AVCaptureDevice.default(for: .video) {
                        self?.isTorchAvailable = device.hasTorch
                    }
                }
            }
        case .denied, .restricted:
            isCameraAvailable = false
            showPermissionAlert = true
        @unknown default:
            isCameraAvailable = false
        }
    }
    
    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            try device.lockForConfiguration()
            
            //checking if torch is available
            if device.hasTorch {
                //toggle flash state
                flashEnabled.toggle()
                
                //config torch mode
                if flashEnabled {
                    try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
                } else {
                    device.torchMode = .off
                }
                
                //save it if preference auto-flash is enabled
                if autoFlashEnabled {
                    UserDefaults.standard.set(flashEnabled, forKey: "LastFlashState")
                }
            }
            
            
            device.unlockForConfiguration()
        } catch {
            print("Error configuring device flash: \(error)")
        
            flashEnabled = device.torchMode == .on
        }
    }
    
    //DataScannerViewControllerDelegate methods
    func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
        switch item {
        case .text(let text):
            self.recognizedText = text.transcript
            self.showTextSheet = true
        default:
            break
        }
    }
    
    func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        if !isScanning {
            return
        }
        
        let texts = addedItems.compactMap { item -> String? in
            switch item {
            case .text(let text):
                return text.transcript
            default:
                return nil
            }
        }
        
        if !texts.isEmpty {
            self.recognizedText = texts.joined(separator: "\n")
        }
    }
    
    func captureText() {
        guard let dataScannerViewController = dataScannerViewController else { return }
        
        //clearing any prev text
        recognizedText = ""
        isScanning = true
        
        Task {
            for try await items in dataScannerViewController.recognizedItems {
                let texts = items.compactMap { item in
                    if case .text(let recognizedText) = item {
                        // Preserve special characters by using raw transcript
                        // and applying minimal processing
                        return recognizedText.transcript
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    return nil
                }
                
                if !texts.isEmpty {
                    DispatchQueue.main.async {
                        // Join with proper line breaks to preserve formatting
                        self.recognizedText = texts.joined(separator: "\n")
                        self.showTextSheet = true
                        self.isScanning = false
                    }
                    break
                }
            }
        }
    }
    
    //tts function
    func speakText(text: String, voice: String) {
        isPlaying = true
        isPaused = false
        playbackProgress = 0
        
        let utterance = AVSpeechUtterance(string: text)
        
        if let voiceToUse = AVSpeechSynthesisVoice(language: voice) {
            utterance.voice = voiceToUse
            utterance.rate = 0.5
            utterance.pitchMultiplier = 1.0
            utterance.volume = 1.0
            
            // Enable word boundary notifications
            utterance.postUtteranceDelay = 0.005
            
            synthesizer.delegate = self
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                synthesizer.stopSpeaking(at: .immediate)
                synthesizer.speak(utterance)
            } catch {
                print("Audio Session error: \(error.localizedDescription)")
            }
        }
    }
    
    func setDataScanner(_ scanner: DataScannerViewController) {
        self.dataScannerViewController = scanner
    }
    
    private func enhanceImage(_ buffer: CVPixelBuffer) -> CVPixelBuffer? {
        let ciImage = CIImage(cvPixelBuffer: buffer)
        
        //applying filters to enhance text
        let filters = [
            "CIColorControls": [
                "inputContrast": 1.1,
                "inputBrightness": 0.1
            ],
            "CIUnsharpMask": [
                "inputRadius": 2.5,
                "inputIntensity": 0.5
            ]
        ]
        
        var processedImage = ciImage
        
        for (filterName, parameters) in filters {
            guard let filter = CIFilter(name: filterName) else { continue }
            filter.setValue(processedImage, forKey: kCIInputImageKey)
            
            for (key, value) in parameters {
                filter.setValue(value, forKey: key)
            }
            
            if let outputImage = filter.outputImage {
                processedImage = outputImage
            }
        }
        
        //converting back to CVPixelBuffer
        var outputBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault,
                           CVPixelBufferGetWidth(buffer),
                           CVPixelBufferGetHeight(buffer),
                           CVPixelBufferGetPixelFormatType(buffer),
                           nil,
                           &outputBuffer)
        
        if let outputBuffer = outputBuffer {
            let context = CIContext()
            context.render(processedImage, to: outputBuffer)
            return outputBuffer
        }
        
        return nil
    }
    
    func provideVoiceGuidance() {
        guard voiceGuidanceEnabled else { return }
        
        let utterance = AVSpeechUtterance(string: "Center the text in the frame")
        utterance.rate = 0.5
        utterance.volume = 1.0
        synthesizer.speak(utterance)
    }
    
    // AVSpeechSynthesizerDelegate methods
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, 
                          willSpeakRangeOfSpeechString characterRange: NSRange, 
                          utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.currentWordRange = Range(characterRange, in: utterance.speechString)
            // Update progress
            let progress = Double(characterRange.location + characterRange.length) / Double(utterance.speechString.count)
            self.playbackProgress = progress
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, 
                          didPause utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isPaused = true
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, 
                          didContinue utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isPaused = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, 
                          didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.currentWordRange = nil
            self.isPlaying = false
            self.isPaused = false
            self.playbackProgress = 1.0
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, 
                          didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.currentWordRange = nil
            self.isPlaying = false
            self.isPaused = false
            self.playbackProgress = 0
        }
    }
}

//MARK:-AVCaptureVideoDataOutputSampleBufferDelegate
extension ScannerManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  let self = self else { return }
            
            let recognizedStrings = observations.compactMap { observation in
                //requestin multiple candidates to improve accuracy
                observation.topCandidates(3).first?.string
            }
            
            DispatchQueue.main.async {
                if !recognizedStrings.isEmpty {
                    self.recognizedText = recognizedStrings.joined(separator: "\n")
                    self.showTextSheet = true
                }
            }
        }
        
        // Configure for better special character recognition
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.customWords = ["©", "®", "™", "€", "£", "¥", "§", "¶"] //spl charac
        request.minimumTextHeight = 0.1 
        
        do {
            try VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        } catch {
            print("Error performing text recognition: \(error)")
        }
    }
}

