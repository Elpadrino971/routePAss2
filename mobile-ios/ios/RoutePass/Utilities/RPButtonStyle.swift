import SwiftUI

struct RPPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .rounded, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, RPTheme.Spacing.lg)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(RPTheme.accent)
            .clipShape(.rect(cornerRadius: RPTheme.buttonRadius))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}

struct RPSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .rounded, weight: .semibold))
            .foregroundStyle(RPTheme.accent)
            .padding(.horizontal, RPTheme.Spacing.lg)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: RPTheme.buttonRadius)
                    .stroke(RPTheme.accent, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}

struct RPGhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.body, design: .rounded, weight: .medium))
            .foregroundStyle(RPTheme.accent)
            .opacity(configuration.isPressed ? 0.5 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}
