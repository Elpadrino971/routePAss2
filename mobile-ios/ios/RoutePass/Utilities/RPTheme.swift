import SwiftUI

enum RPTheme {
    static let accent = Color(red: 212/255, green: 168/255, blue: 67/255)
    static let accentDark = Color(red: 180/255, green: 140/255, blue: 50/255)

    static let textPrimary = Color(.label)
    static let textSecondary = Color(red: 142/255, green: 142/255, blue: 147/255)
    static let separator = Color(red: 242/255, green: 242/255, blue: 247/255)

    static let backgroundPrimary = Color(.systemBackground)
    static let backgroundSecondary = Color(.secondarySystemBackground)

    static let cardRadius: CGFloat = 20
    static let buttonRadius: CGFloat = 14

    static let cardShadow: Color = .black.opacity(0.08)
    static let cardShadowRadius: CGFloat = 10
    static let cardShadowY: CGFloat = 4

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
    }
}
