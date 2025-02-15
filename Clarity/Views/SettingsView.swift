import SwiftUI

struct SettingsView: View {
    @ObservedObject var scannerManager: ScannerManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("defaultTextSize") private var defaultTextSize: Double = 16
    
    var body: some View {
        NavigationStack {
            List {
                // Camera Settings Section
                Section {
                    SettingsToggle(
                        isOn: $scannerManager.autoFlashEnabled,
                        icon: "bolt.fill",
                        title: "Auto Flash",
                        subtitle: "Automatically enable flash in low light"
                    )
                    
                    SettingsToggle(
                        isOn: $scannerManager.showGuidelines,
                        icon: "grid",
                        title: "Show Guidelines",
                        subtitle: "Display scanning frame guides"
                    )
                } header: {
                    SettingsSectionHeader(title: "Camera", icon: "camera.fill")
                }
                
                // Accessibility Section
                Section {
                    SettingsToggle(
                        isOn: $scannerManager.voiceGuidanceEnabled,
                        icon: "mic.fill",
                        title: "Voice Guidance",
                        subtitle: "Spoken instructions while scanning"
                    )
                    
                    NavigationLink {
                        VoiceSelectionView(selectedVoice: $scannerManager.defaultVoice)
                    } label: {
                        SettingsRow(
                            icon: "speaker.wave.2.fill",
                            title: "Default Voice",
                            subtitle: "Select text-to-speech voice"
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        SettingsRow(
                            icon: "textformat.size",
                            title: "Text Size",
                            subtitle: "Adjust default text size"
                        )
                        
                        HStack {
                            Text("A").font(.caption)
                            Slider(value: $defaultTextSize,
                                   in: 12...32,
                                   step: 1)
                                .tint(AppTheme.accent)
                            Text("A").font(.title3)
                        }
                        .padding(.leading, 30)
                    }
                    .padding(.vertical, 4)
                } header: {
                    SettingsSectionHeader(title: "Accessibility", icon: "accessibility")
                }
                
                // Appearance Section
                Section {
                    NavigationLink {
                        ThemeSelectionView()
                    } label: {
                        SettingsRow(
                            icon: "paintpalette.fill",
                            title: "Theme",
                            subtitle: "Customize app appearance"
                        )
                    }
                } header: {
                    SettingsSectionHeader(title: "Appearance", icon: "paintbrush.fill")
                }
                
                // About Section
                Section {
                    Link(destination: URL(string: "https://help.example.com")!) {
                        SettingsRow(
                            icon: "questionmark.circle.fill",
                            title: "Help & Feedback",
                            subtitle: "Get support and share feedback"
                        )
                    }
                    
                    SettingsRow(
                        icon: "info.circle.fill",
                        title: "Version",
                        value: "1.0.0"
                    )
                } header: {
                    SettingsSectionHeader(title: "About", icon: "info.circle.fill")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppTheme.accent)
                }
            }
        }
    }
}

// Helper Views for consistent styling
struct SettingsSectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.accent)
                .font(.system(size: 14, weight: .semibold))
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .textCase(nil)
        }
        .padding(.bottom, 4)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var value: String? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppTheme.accent)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16))
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .foregroundColor(.secondary)
                    .font(.system(size: 15))
            }
        }
        .padding(.vertical, 4)
    }
}

struct SettingsToggle: View {
    @Binding var isOn: Bool
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        Toggle(isOn: $isOn) {
            SettingsRow(
                icon: icon,
                title: title,
                subtitle: subtitle
            )
        }
        .tint(AppTheme.accent)
    }
}

struct VoiceSelectionView: View {
    @Binding var selectedVoice: String
    let voices = [
        ("🇮🇳", "Indian English", "en-IN"),
        ("🇬🇧", "UK English", "en-GB"),
        ("🇺🇸", "US English", "en-US"),
        ("🇦🇺", "Australian English", "en-AU")
    ]
    
    var body: some View {
        List {
            ForEach(voices, id: \.2) { flag, name, code in
                Button(action: { selectedVoice = code }) {
                    HStack {
                        Text(flag)
                        Text(name)
                        Spacer()
                        if selectedVoice == code {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppTheme.accent)
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Voice")
    }
} 