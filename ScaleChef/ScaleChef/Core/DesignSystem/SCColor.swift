import SwiftUI

struct SCColor {
    static let primary = Color(red: 0.91, green: 0.45, blue: 0.16)
    static let secondary = Color(red: 0.18, green: 0.42, blue: 0.31)
    static let background = Color(red: 1.0, green: 0.98, blue: 0.96)
    static let surface = Color.white
    static let textPrimary = Color(red: 0.10, green: 0.10, blue: 0.18)
    static let textSecondary = Color(red: 0.42, green: 0.45, blue: 0.50)
    static let warning = Color(red: 0.96, green: 0.62, blue: 0.04)
    static let error = Color(red: 0.94, green: 0.27, blue: 0.27)
    static let success = Color(red: 0.06, green: 0.73, blue: 0.51)

    static let primaryDark = Color(red: 1.0, green: 0.55, blue: 0.25)
    static let secondaryDark = Color(red: 0.25, green: 0.55, blue: 0.40)
    static let backgroundDark = Color(red: 0.08, green: 0.08, blue: 0.12)
    static let surfaceDark = Color(red: 0.14, green: 0.14, blue: 0.20)
    static let textPrimaryDark = Color.white
    static let textSecondaryDark = Color(red: 0.65, green: 0.68, blue: 0.73)
}

extension Color {
    static var scPrimary: Color {
        Color(light: SCColor.primary, dark: SCColor.primaryDark)
    }
    static var scSecondary: Color {
        Color(light: SCColor.secondary, dark: SCColor.secondaryDark)
    }
    static var scBackground: Color {
        Color(light: SCColor.background, dark: SCColor.backgroundDark)
    }
    static var scSurface: Color {
        Color(light: SCColor.surface, dark: SCColor.surfaceDark)
    }
    static var scTextPrimary: Color {
        Color(light: SCColor.textPrimary, dark: SCColor.textPrimaryDark)
    }
    static var scTextSecondary: Color {
        Color(light: SCColor.textSecondary, dark: SCColor.textSecondaryDark)
    }
    static var scWarning: Color { SCColor.warning }
    static var scError: Color { SCColor.error }
    static var scSuccess: Color { SCColor.success }

    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
