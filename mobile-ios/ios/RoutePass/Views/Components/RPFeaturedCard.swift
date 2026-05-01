import SwiftUI

/// Card "En vedette" — verticale, photo en haut prenant tout le bandeau,
/// titre + prix en overlay sur l'image (style mockup).
struct RPFeaturedCard: View {
    let item: RPCardItem
    @State private var appeared: Bool = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RPImage(url: item.imageURL, fallback: item.imageName)
                .frame(width: 240, height: 200)

            // Overlay dégradé bottom→top pour lisibilité du texte
            LinearGradient(
                colors: [.black.opacity(0.0), .black.opacity(0.7), .black.opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 240, height: 200)

            // Top : badge status
            VStack {
                HStack {
                    RPBadge(status: item.status, compact: true)
                    Spacer()
                }
                Spacer()
            }
            .padding(10)
            .frame(width: 240, height: 200)

            // Bottom : titre + sous-titre + prix
            VStack(alignment: .leading, spacing: 4) {
                if let availableAt = item.availableAt {
                    Text(availableAt)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(RPTheme.info)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(RPTheme.info.opacity(0.2)))
                }
                Text(item.title)
                    .font(RPFont.body(15, weight: .semibold))
                    .foregroundStyle(RPTheme.white)
                    .lineLimit(1)
                Text(item.subtitle)
                    .font(RPFont.body(11))
                    .foregroundStyle(RPTheme.gray)
                    .lineLimit(1)
                Text(item.price)
                    .font(RPFont.mono(14, weight: .semibold))
                    .foregroundStyle(RPTheme.gold)
            }
            .padding(12)
            .frame(width: 240, alignment: .leading)
        }
        .frame(width: 240, height: 200)
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        .overlay(
            RoundedRectangle(cornerRadius: RPTheme.cardRadius)
                .stroke(RPTheme.border, lineWidth: 1)
        )
        .rpCardShadow()
        .scaleEffect(appeared ? 1 : 0.96)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                appeared = true
            }
        }
    }
}
