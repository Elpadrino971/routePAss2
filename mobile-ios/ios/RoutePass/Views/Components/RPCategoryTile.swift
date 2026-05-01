import SwiftUI

/// Tuile catégorie pour la page Transport — icône or sur card sombre, label,
/// compteur "X dispo". Carrée, prend toute sa colonne dans une grille 2x2.
struct RPCategoryTile: View {
    let icon: String
    let label: String
    let availableCount: Int
    var imageURL: String? = nil
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                // Image distante optionnelle (vraie photo si fournie)
                if let imageURL {
                    RPImage(url: imageURL, fallback: icon)
                        .frame(maxWidth: .infinity)
                        .frame(height: 110)
                } else {
                    LinearGradient(
                        colors: [RPTheme.dark2, RPTheme.dark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 38, weight: .light))
                            .foregroundStyle(RPTheme.goldMuted.opacity(0.5))
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 110)
                }

                // Vignette top→bottom pour lisibilité
                LinearGradient(
                    colors: [.black.opacity(0), .black.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 110)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: icon)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(RPTheme.gold)
                        Text(label)
                            .font(RPFont.body(13, weight: .semibold))
                            .foregroundStyle(RPTheme.white)
                    }
                    Text("\(availableCount) dispo")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(RPTheme.gray)
                }
                .padding(10)
            }
            .frame(height: 110)
            .background(RPTheme.dark)
            .overlay(
                RoundedRectangle(cornerRadius: RPTheme.cardRadius)
                    .stroke(RPTheme.border, lineWidth: 1)
            )
            .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
            .rpCardShadow()
        }
        .buttonStyle(.plain)
    }
}
