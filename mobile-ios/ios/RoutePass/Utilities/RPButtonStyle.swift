import SwiftUI

/// Bouton primaire ROUTEPASS — dégradé or sur fond noir, texte sombre.
struct RPPrimaryButtonStyle: ButtonStyle {
    var size: RPButtonSize = .md
    var block: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size.font, weight: .semibold))
            .foregroundStyle(RPTheme.black)
            .padding(.horizontal, size.hPadding)
            .padding(.vertical, size.vPadding)
            .frame(maxWidth: block ? .infinity : nil)
            .background(RPTheme.goldGradient)
            .clipShape(.rect(cornerRadius: RPTheme.buttonRadius))
            .shadow(color: RPTheme.gold.opacity(0.25), radius: 12, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}

/// Bouton secondaire — bordure or, fond sombre.
struct RPSecondaryButtonStyle: ButtonStyle {
    var size: RPButtonSize = .md
    var block: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size.font, weight: .semibold))
            .foregroundStyle(RPTheme.gold)
            .padding(.horizontal, size.hPadding)
            .padding(.vertical, size.vPadding)
            .frame(maxWidth: block ? .infinity : nil)
            .background(RPTheme.dark)
            .overlay(
                RoundedRectangle(cornerRadius: RPTheme.buttonRadius)
                    .stroke(RPTheme.gold.opacity(0.6), lineWidth: 1)
            )
            .clipShape(.rect(cornerRadius: RPTheme.buttonRadius))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}

/// Bouton ghost — texte or, sans fond.
struct RPGhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, weight: .medium))
            .foregroundStyle(RPTheme.gold)
            .opacity(configuration.isPressed ? 0.5 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}

/// Bouton destructif — rouge plein.
struct RPDestructiveButtonStyle: ButtonStyle {
    var size: RPButtonSize = .md
    var block: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size.font, weight: .semibold))
            .foregroundStyle(RPTheme.white)
            .padding(.horizontal, size.hPadding)
            .padding(.vertical, size.vPadding)
            .frame(maxWidth: block ? .infinity : nil)
            .background(RPTheme.danger)
            .clipShape(.rect(cornerRadius: RPTheme.buttonRadius))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}

enum RPButtonSize {
    case sm, md, lg

    var font: CGFloat {
        switch self {
        case .sm: 14
        case .md: 16
        case .lg: 17
        }
    }
    var hPadding: CGFloat {
        switch self {
        case .sm: 16
        case .md: 24
        case .lg: 28
        }
    }
    var vPadding: CGFloat {
        switch self {
        case .sm: 10
        case .md: 14
        case .lg: 18
        }
    }
}
