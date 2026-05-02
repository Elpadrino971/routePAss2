import SwiftUI

/// Header de section ROUTEPASS — petit "kicker" or au-dessus du titre, icône
/// dans une tuile sombre à gauche, titre serif blanc + sous-titre gris.
struct RPSectionHeader: View {
    let title: String
    let subtitle: String
    let icon: String
    var kicker: String? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(RPTheme.dark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(RPTheme.gold.opacity(0.4), lineWidth: 1)
                    )
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(RPTheme.gold)
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 2) {
                if let kicker {
                    Text(kicker.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .tracking(2.5)
                        .foregroundStyle(RPTheme.gold)
                }
                Text(title)
                    .font(RPFont.display(22))
                    .foregroundStyle(RPTheme.white)
                Text(subtitle)
                    .font(RPFont.body(12))
                    .foregroundStyle(RPTheme.gray)
            }
            Spacer()
        }
        .padding(.horizontal, RPTheme.Spacing.lg)
        .padding(.top, 12)
        .padding(.bottom, 14)
    }
}
