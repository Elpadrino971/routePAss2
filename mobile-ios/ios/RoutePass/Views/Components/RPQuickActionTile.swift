import SwiftUI

/// Tuile d'action rapide ROUTEPASS — petit carré dark luxury avec
/// icône or, label en bas. Utilisée dans la grille de l'Accueil
/// ("Me déplacer / Accéder / Scan / Bons").
struct RPQuickActionTile: View {
    let icon: String
    let label: String
    var isHighlighted: Bool = false
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(isHighlighted ? RPTheme.goldGradient : LinearGradient(colors: [RPTheme.dark, RPTheme.dark2], startPoint: .top, endPoint: .bottom))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(isHighlighted ? RPTheme.gold.opacity(0.6) : RPTheme.border, lineWidth: 1)
                        )

                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(isHighlighted ? RPTheme.black : RPTheme.gold)
                }
                .frame(width: 64, height: 64)
                .rpCardShadow()

                Text(label)
                    .font(RPFont.body(11, weight: .medium))
                    .foregroundStyle(RPTheme.gray)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}
