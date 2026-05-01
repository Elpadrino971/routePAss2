import SwiftUI

/// Card universelle ROUTEPASS — layout horizontal pour les listes
/// "Récemment consultés" sur l'Accueil. Image à gauche, infos à droite,
/// badges Status (top-left de l'image) et "Principal" (top-right) flottants.
struct RPCard: View {
    let item: RPCardItem
    @State private var appeared: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Image bloc
            ZStack(alignment: .topLeading) {
                RPImage(url: item.imageURL, fallback: item.imageName)
                    .frame(width: 130, height: 110)

                RPBadge(status: item.status, compact: true)
                    .padding(8)

                if item.isPrincipal {
                    VStack(alignment: .trailing) {
                        HStack {
                            Spacer()
                            RPTagBadge(text: "Principal", color: RPTheme.danger)
                        }
                        Spacer()
                    }
                    .padding(8)
                    .frame(width: 130, height: 110, alignment: .topTrailing)
                }
            }
            .frame(width: 130, height: 110)
            .clipped()

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(RPFont.body(15, weight: .semibold))
                    .foregroundStyle(RPTheme.white)
                    .lineLimit(1)

                Text(item.subtitle)
                    .font(RPFont.body(11))
                    .foregroundStyle(RPTheme.gray)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Text(item.price)
                    .font(RPFont.mono(15, weight: .semibold))
                    .foregroundStyle(RPTheme.gold)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
        }
        .background(RPTheme.dark)
        .overlay(
            RoundedRectangle(cornerRadius: RPTheme.cardRadius)
                .stroke(RPTheme.border, lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        .rpCardShadow()
        .scaleEffect(appeared ? 1 : 0.97)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                appeared = true
            }
        }
    }
}

/// Conteneur image — AsyncImage si URL, fallback SF Symbol or sur fond sombre.
struct RPImage: View {
    let url: String?
    let fallback: String
    var contentMode: ContentMode = .fill

    var body: some View {
        Group {
            if let url, let parsed = URL(string: url) {
                AsyncImage(url: parsed) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: contentMode)
                    case .empty:
                        placeholder.overlay(ProgressView().tint(RPTheme.gold))
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .clipped()
    }

    private var placeholder: some View {
        ZStack {
            RPTheme.dark2
            Image(systemName: fallback)
                .font(.system(size: 28))
                .foregroundStyle(RPTheme.goldMuted)
        }
    }
}
