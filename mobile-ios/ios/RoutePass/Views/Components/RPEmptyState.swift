import SwiftUI

/// Empty state ROUTEPASS — icône or sur cercle dark, titre serif, message,
/// bouton optionnel. Tout le bloc est dans une card en pointillés.
struct RPEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(RPTheme.dark2)
                    .frame(width: 64, height: 64)
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .light))
                    .foregroundStyle(RPTheme.gold)
            }

            VStack(spacing: 6) {
                Text(title)
                    .font(RPFont.display(18))
                    .foregroundStyle(RPTheme.white)

                Text(message)
                    .font(RPFont.body(13))
                    .foregroundStyle(RPTheme.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(RPPrimaryButtonStyle(size: .sm, block: false))
                    .padding(.top, 4)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: RPTheme.cardRadius, style: .continuous)
                .fill(RPTheme.dark.opacity(0.4))
        )
        .overlay(
            RoundedRectangle(cornerRadius: RPTheme.cardRadius, style: .continuous)
                .strokeBorder(RPTheme.border, style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
        )
        .accessibilityElement(children: .combine)
    }
}
