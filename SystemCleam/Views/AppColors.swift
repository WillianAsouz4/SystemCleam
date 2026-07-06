import SwiftUI
import AppKit

extension NSColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(nsColor: NSColor(hex: hex, alpha: alpha))
    }

    /// A color that swaps between two fixed hex values based on the system's
    /// light/dark appearance, independent of the accent/tint system colors.
    init(light: UInt32, dark: UInt32, lightAlpha: Double = 1, darkAlpha: Double = 1) {
        let lightColor = NSColor(hex: light, alpha: lightAlpha)
        let darkColor = NSColor(hex: dark, alpha: darkAlpha)
        let dynamic = NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? darkColor : lightColor
        }
        self.init(nsColor: dynamic)
    }
}

enum AppColors {
    static let panelBackground = Color(light: 0xECEEF1, dark: 0x1B1C1F)
    static let cardBackground = Color(light: 0xFFFFFF, dark: 0x28292D)
    static let secondaryText = Color(light: 0x6B6D74, dark: 0x97989F)
    static let hairline = Color(light: 0x000000, dark: 0xFFFFFF, lightAlpha: 0.08, darkAlpha: 0.09)
    static let accent = Color(hex: 0x0F9488)
    static let danger = Color(hex: 0xD6493C)
}

extension CleanupCategory {
    var color: Color {
        switch self {
        case .appCaches:
            return Color(hex: 0x3B82C4)
        case .appLeftovers:
            return Color(hex: 0xD9861F)
        case .largeFiles:
            return Color(hex: 0x8B5CC7)
        }
    }
}
