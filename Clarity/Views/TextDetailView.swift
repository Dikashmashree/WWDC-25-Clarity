import SwiftUI
import AVFoundation

struct TextDetailView: View {
    let text: String
    @ObservedObject var scannerManager: ScannerManager
    @State private var selectedVoice: String
    @State private var fontSize: CGFloat
    @State private var isBold: Bool
    @State private var showVoiceOptions = false
    @State private var showStats = false
    @State private var showExportOptions = false
    @State private var showSaveDialog = false
    @State private var scanTitle = ""
    
    init(text: String, scannerManager: ScannerManager) {
        self.text = text
        self.scannerManager = scannerManager
        _selectedVoice = State(initialValue: scannerManager.defaultVoice)
        _fontSize = State(initialValue: scannerManager.defaultTextSize)
        _isBold = State(initialValue: scannerManager.isBoldText)
    }
    
    let voiceOptions: [(icon: String, flag: String, name: String, code: String)] = [
        ("globe.asia.australia.fill", "🇮🇳", "Indian English", "en-IN"),
        ("globe.europe.africa.fill", "🇬🇧", "UK English", "en-GB"),
        ("globe.americas.fill", "🇺🇸", "US English", "en-US"),
        ("globe.asia.australia.fill", "🇦🇺", "Aussie English", "en-AU")
    ]
    
    var selectedVoiceName: String {
        voiceOptions.first { $0.code == selectedVoice }?.name ?? "US English"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.padding) {
                controlsBar
                    .padding(.horizontal)
                    .modifier(AppTheme.cardStyle())
                
                textView
            
                voiceControlBar
                    .padding(.horizontal)
                    .modifier(AppTheme.cardStyle())
        
                actionButtonsBar
            }
            .padding()
            .background(AppTheme.primaryBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    menuButton
                }
            }
            .sheet(isPresented: $showVoiceOptions) {
                VoiceOptionsSheet(selectedVoice: $selectedVoice, voices: voiceOptions)
            }
            .sheet(isPresented: $showStats) {
                TextStatsView(text: text)
            }
            .sheet(isPresented: $showExportOptions) {
                ExportOptionsView(text: text)
            }
            .alert("Save Scan", isPresented: $showSaveDialog) {
                TextField("Title", text: $scanTitle)
                Button("Save") {
                    scannerManager.saveCurrentScan(title: scanTitle)
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
    
    private var controlsBar: some View {
        HStack(spacing: AppTheme.padding) {

            HStack {
                Button(action: { fontSize = max(fontSize - 2, 12) }) {
                    Image(systemName: "textformat.size.smaller")
                        .modifier(AppTheme.iconButtonStyle())
                }
                
                Slider(value: $fontSize, in: 12...32, step: 1)
                    .tint(AppTheme.accent)
                
                Button(action: { fontSize = min(fontSize + 2, 32) }) {
                    Image(systemName: "textformat.size.larger")
                        .modifier(AppTheme.iconButtonStyle())
                }
            }
            
            Button(action: { isBold.toggle() }) {
                Image(systemName: isBold ? "bold" : "bold.slash")
                    .modifier(AppTheme.iconButtonStyle(isActive: isBold))
            }
        }
    }
    
    private var textView: some View {
        ScrollView {
            if scannerManager.isPlaying {
                HighlightedText(
                    text: text,
                    highlightRange: scannerManager.currentWordRange,
                    fontSize: fontSize,
                    isBold: isBold
                )
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .modifier(AppTheme.cardStyle())
            } else {
                Text(text)
                    .font(.system(size: fontSize, weight: isBold ? .bold : .regular))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(AppTheme.cardStyle())
            }
        }
    }
    
    private var voiceControlBar: some View {
        VStack(spacing: 12) {
            // Voice selector
            Button(action: { showVoiceOptions.toggle() }) {
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2")
                    Text(voiceOptions.first { $0.code == selectedVoice }?.flag ?? "🇺🇸")
                    Text(selectedVoiceName)
                        .lineLimit(1)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.ButtonStyle.secondaryBackground)
                .cornerRadius(20)
            }
            
            // Playback controls
            HStack(spacing: 24) {
                // Replay button
                Button(action: {
                    scannerManager.synthesizer.stopSpeaking(at: .immediate)
                    scannerManager.speakText(text: text, voice: selectedVoice)
                    HapticManager.shared.selectionFeedback()
                }) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.accent)
                        .opacity(scannerManager.isPlaying ? 1 : 0.6)
                }
                
                // Play/Pause button
                Button(action: {
                    if scannerManager.isPlaying {
                        scannerManager.synthesizer.pauseSpeaking(at: .word)
                    } else if scannerManager.synthesizer.isPaused {
                        scannerManager.synthesizer.continueSpeaking()
                    } else {
                        scannerManager.speakText(text: text, voice: selectedVoice)
                    }
                    HapticManager.shared.selectionFeedback()
                }) {
                    Image(systemName: scannerManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(AppTheme.accent)
                        .symbolEffect(.bounce, value: scannerManager.isPlaying)
                }
                
                // Stop button
                Button(action: {
                    scannerManager.synthesizer.stopSpeaking(at: .immediate)
                    HapticManager.shared.selectionFeedback()
                }) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.accent)
                        .opacity(scannerManager.isPlaying ? 1 : 0.6)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var actionButtonsBar: some View {
        HStack(spacing: AppTheme.padding * 2) {
            ForEach([
                ("Copy", "doc.on.doc.fill", { UIPasteboard.general.string = text }),
                ("Share", "square.and.arrow.up", { /* share action */ })
            ], id: \.0) { title, icon, action in
                Button(action: action) {
                    VStack(spacing: 4) {
                        Image(systemName: icon)
                            .font(.title2)
                        Text(title)
                            .font(.caption2)
                    }
                    .foregroundColor(AppTheme.accent)
                }
            }
        }
        .padding()
        .modifier(AppTheme.cardStyle())
    }
    
    private var menuButton: some View {
        Menu {
            Button(action: { showStats = true }) {
                Label("Statistics", systemImage: "chart.bar")
            }
            
            Button(action: { showSaveDialog = true }) {
                Label("Save", systemImage: "square.and.arrow.down")
            }
            
            Button(action: { showExportOptions = true }) {
                Label("Export", systemImage: "square.and.arrow.up")
            }
            
            // Quick actions based on text type
            if let url = URL(string: text), UIApplication.shared.canOpenURL(url) {
                Button(action: { UIApplication.shared.open(url) }) {
                    Label("Open URL", systemImage: "safari")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title2)
        }
    }
}

struct VoiceOptionsSheet: View {
    @Binding var selectedVoice: String
    let voices: [(icon: String, flag: String, name: String, code: String)]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(voices, id: \.code) { voice in
                    Button(action: {
                        selectedVoice = voice.code
                        dismiss()
                    }) {
                        HStack(spacing: AppTheme.padding) {
                            Text(voice.flag)
                                .font(.title2)
                            
                            Text(voice.name)
                                .foregroundColor(AppTheme.text)
                            
                            Spacer()
                            
                            if selectedVoice == voice.code {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AppTheme.accent)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Select Voice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppTheme.accent)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct TextStatsView: View {
    let text: String
    let stats: TextStats
    
    init(text: String) {
        self.text = text
        self.stats = TextStats(text: text)
    }
    
    var body: some View {
        List {
            StatRow(title: "Words", value: stats.wordCount)
            StatRow(title: "Characters", value: stats.charCount)
            StatRow(title: "Lines", value: stats.lineCount)
        }
        .navigationTitle("Text Statistics")
    }
}

struct StatRow: View {
    let title: String
    let value: Int
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(value)")
                .foregroundColor(.secondary)
        }
    }
}

struct GestureControlView: View {
    @ObservedObject var scannerManager: ScannerManager
    let text: String
    
    var body: some View {
        VStack {
            Text(text)
                .font(.system(size: fontSize, weight: isBold ? .bold : .regular))
                .gesture(
                    MagnificationGesture()
                        .onChanged { scale in
                            fontSize = min(max(defaultSize * scale, 12), 40)
                            HapticManager.shared.selectionFeedback()
                        }
                )
                .gesture(
                    DragGesture(minimumDistance: 50)
                        .onEnded { value in
                            if abs(value.translation.width) > abs(value.translation.height) {
                                // Horizontal swipe for next/previous section
                                HapticManager.shared.selectionFeedback()
                            }
                        }
                )
        }
    }
}

struct AccessibleTextView: View {
    @State private var letterSpacing: CGFloat = 0
    @State private var lineSpacing: CGFloat = 8
    
    var body: some View {
        VStack {
            Text(text)
                .tracking(letterSpacing)
                .lineSpacing(lineSpacing)
            
            // Quick access controls
            HStack {
                Button(action: { letterSpacing -= 0.5 }) {
                    Image(systemName: "text.compress")
                }
                Button(action: { letterSpacing += 0.5 }) {
                    Image(systemName: "text.append")
                }
                Button(action: { lineSpacing -= 2 }) {
                    Image(systemName: "arrow.up.and.down.text.horizontal")
                }
                Button(action: { lineSpacing += 2 }) {
                    Image(systemName: "arrow.up.and.down")
                }
            }
        }
    }
}

struct FocusedReadingView: View {
    @State private var focusMode = false
    
    var body: some View {
        VStack {
            if focusMode {
                // Show one paragraph at a time
                Text(currentParagraph)
                    .transition(.slide)
            } else {
                Text(fullText)
            }
            
            Button(action: { focusMode.toggle() }) {
                Label(
                    focusMode ? "Exit Focus Mode" : "Enter Focus Mode",
                    systemImage: focusMode ? "eye.slash" : "eye"
                )
            }
        }
    }
}

struct HighlightedText: View {
    let text: String
    let highlightRange: Range<String.Index>?
    let fontSize: CGFloat
    let isBold: Bool
    
    var body: some View {
        Text(text.prefix(upTo: highlightRange?.lowerBound ?? text.endIndex))
            .font(.system(size: fontSize, weight: isBold ? .bold : .regular))
            .foregroundColor(AppTheme.text) +
        
        Text(highlightRange.map { text[$0] } ?? "")
            .font(.system(size: fontSize, weight: .bold))
            .foregroundColor(AppTheme.accent)
            .background(AppTheme.accent.opacity(0.2)) +
        
        Text(text.suffix(from: highlightRange?.upperBound ?? text.startIndex))
            .font(.system(size: fontSize, weight: isBold ? .bold : .regular))
            .foregroundColor(AppTheme.text)
    }
}

