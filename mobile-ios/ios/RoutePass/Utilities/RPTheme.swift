import SwiftUI

/// ROUTEPASS — Dark luxury strict.
/// Couleurs alignées sur le master prompt et la web app Next.js.
enum RPTheme {
    // Fond / surfaces
    static let black       = Color(hex: 0x08080D)   // fond principal
    static let dark        = Color(hex: 0x0F0F18)   // cards, surfaces
    static let dark2       = Color(hex: 0x16161F)   // hover, inputs
    static let border      = Color(hex: 0x1E1E2E)   // séparateurs

    // Or signature
    static let gold        = Color(hex: 0xC9A84C)
    static let goldLight   = Color(hex: 0xE8C96A)
    static let goldMuted   = Color(hex: 0x8B6E2A)

    // Textes
    static let white       = Color(hex: 0xF5F0E8)
    static let gray        = Color(hex: 0x6B6B7B)

    // Statuts
    static let success     = Color(hex: 0x22C55E)
    static let danger      = Color(hex: 0xEF4444)
    static let warning     = Color(hex: 0xF59E0B)
    static let info        = Color(hex: 0x3B82F6)

    // Aliases historiques (compatibilité avec le code Rork existant)
    static var backgroundPrimary: Color   { black }
    static var backgroundSecondary: Color { dark }
    static var accent: Color              { gold }
    static var accentDark: Color          { goldMuted }
    static var textPrimary: Color         { white }
    static var textSecondary: Color       { gray }
    static var separator: Color           { border }

    // Géométrie
    static let cardRadius: CGFloat = 20
    static let buttonRadius: CGFloat = 12
    static let inputRadius: CGFloat = 8

    static let cardShadow: Color = .black.opacity(0.4)
    static let cardShadowRadius: CGFloat = 16
    static let cardShadowY: CGFloat = 8

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
    }

    /// Dégradé or signature ROUTEPASS.
    static let goldGradient = LinearGradient(
        colors: [goldLight, gold, goldMuted],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color hex helper

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >>  8) & 0xFF) / 255
        let b = Double( hex        & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

// MARK: - Typography

enum RPFont {
    /// Titres "display" — Playfair Display si embarqué, sinon serif système.
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        if UIFont(name: "PlayfairDisplay-Bold", size: size) != nil {
            return Font.custom("PlayfairDisplay-Bold", size: size)
        }
        return Font.system(size: size, weight: weight, design: .serif)
    }

    static func displayItalic(_ size: CGFloat) -> Font {
        if UIFont(name: "PlayfairDisplay-BoldItalic", size: size) != nil {
            return Font.custom("PlayfairDisplay-BoldItalic", size: size)
        }
        return Font.system(size: size, weight: .bold, design: .serif).italic()
    }

    /// Texte courant — Inter si embarqué, sinon SF Pro.
    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if UIFont(name: "Inter-Regular", size: size) != nil {
            return Font.custom("Inter-Regular", size: size)
        }
        return Font.system(size: size, weight: weight, design: .default)
    }

    /// Mono — JetBrains Mono si embarqué, sinon SF Mono.
    static func mono(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        if UIFont(name: "JetBrainsMono-Medium", size: size) != nil {
            return Font.custom("JetBrainsMono-Medium", size: size)
        }
        return Font.system(size: size, weight: weight, design: .monospaced)
    }

    /// Petite cap "kicker" — pour les labels "TRANSPORT", "ACCUEIL", etc.
    static let kicker = Font.system(size: 11, weight: .semibold, design: .default)
}

extension View {
    /// Ombre signature des cards ROUTEPASS.
    func rpCardShadow() -> some View {
        self.shadow(
            color: RPTheme.cardShadow,
            radius: RPTheme.cardShadowRadius,
            x: 0,
            y: RPTheme.cardShadowY
        )
    }

    /// Petite cap dorée espacée — "TRANSPORT", "ACCUEIL", etc.
    func rpKicker() -> some View {
        self
            .font(RPFont.kicker)
            .tracking(3)
            .foregroundStyle(RPTheme.gold)
            .textCase(.uppercase)
    }
}
