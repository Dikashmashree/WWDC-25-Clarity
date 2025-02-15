import SwiftUI

enum AppTheme {
    // Colors
    static let primaryBackground = Color("PrimaryBackground")
    static let secondaryBackground = Color("SecondaryBackground")
    static let accent = Color("AccentColor")
    static let text = Color("TextColor")
    static let overlay = Color("OverlayColor")
    
    // Dimensions
    static let cornerRadius: CGFloat = 16
    static let padding: CGFloat = 16
    static let buttonSize: CGFloat = 56
    static let iconSize: CGFloat = 24
    
    // Animations
    static let defaultAnimation: Animation = .spring(response: 0.3, dampingFraction: 0.7)
    
    struct ButtonStyle {
        static let primaryBackground = Color("ButtonBackground")
        static let secondaryBackground = Color("ButtonSecondaryBackground")
        static let shadow = Color("ButtonShadow")
    }
    
    // Common modifiers
    static func cardStyle() -> some ViewModifier {
        ViewModifier { content in
            content
                .background(AppTheme.secondaryBackground)
                .cornerRadius(AppTheme.cornerRadius)
                .shadow(color: ButtonStyle.shadow.opacity(0.1),
                        radius: 8, x: 0, y: 2)
        }
    }
    
    static func iconButtonStyle(isActive: Bool = false) -> some ViewModifier {
        ViewModifier { content in
            content
                .font(.system(size: AppTheme.iconSize, weight: .semibold))
                .foregroundColor(isActive ? accent : text)
                .frame(width: AppTheme.buttonSize, height: AppTheme.buttonSize)
                .background(ButtonStyle.secondaryBackground)
                .cornerRadius(AppTheme.buttonSize / 2)
                .shadow(color: ButtonStyle.shadow.opacity(0.15),
                        radius: 6, x: 0, y: 3)
        }
    }
    
    static func adaptiveCardStyle(for colorScheme: ColorScheme) -> some ViewModifier {
        ViewModifier { content in
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(secondaryBackground)
                        .shadow(
                            color: colorScheme == .dark 
                                ? .white.opacity(0.05) 
                                : .black.opacity(0.1),
                            radius: colorScheme == .dark ? 12 : 8,
                            x: 0,
                            y: colorScheme == .dark ? -2 : 2
                        )
                )
        }
    }
}

enum VisionPreset: String, CaseIterable {
    case standard = "Standard"
    case highContrast = "High Contrast"
    case softLight = "Soft Light"
    case warmColors = "Warm Colors"
    
    var textColor: Color {
        switch self {
        case .standard: return .primary
        case .highContrast: return .white
        case .softLight: return Color(red: 0.2, green: 0.2, blue: 0.3)
        case .warmColors: return Color(red: 0.3, green: 0.1, blue: 0)
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .standard: return .background
        case .highContrast: return .black
        case .softLight: return Color(red: 0.95, green: 0.95, blue: 0.97)
        case .warmColors: return Color(red: 1, green: 0.97, blue: 0.9)
        }
    }
} 