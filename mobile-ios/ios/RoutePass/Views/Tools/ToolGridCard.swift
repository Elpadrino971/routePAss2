import SwiftUI

/// Card grid Outils — photo Unsplash en haut (130pt), titre + marque/modèle,
/// étoiles, prix or, badge état dans l'image, le tout en dark luxury.
struct ToolGridCard: View {
    let tool: ToolItem
    @State private var appeared: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                RPImage(url: tool.gallery.first, fallback: tool.icon)
                    .frame(height: 130)

                LinearGradient(
                    colors: [.black.opacity(0), .black.opacity(0.55)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 130)

                RPBadge(status: tool.status, compact: true)
                    .padding(8)

                if tool.deliveryAvailable {
                    VStack {
                        HStack {
                            Spacer()
                            HStack(spacing: 3) {
                                Image(systemName: "shippingbox.fill").font(.system(size: 9))
                                Text("Livraison").font(.system(size: 9, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(.black.opacity(0.55)))
                        }
                        Spacer()
                    }
                    .padding(8)
                }
            }
            .frame(height: 130)
            .clipped()

            VStack(alignment: .leading, spacing: 5) {
                Text(tool.name)
                    .font(RPFont.body(13, weight: .semibold))
                    .foregroundStyle(RPTheme.white)
                    .lineLimit(1)

                Text("\(tool.brand) · \(tool.model)")
                    .font(RPFont.body(10))
                    .foregroundStyle(RPTheme.gray)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(RPTheme.warning)
                    Text(String(format: "%.1f", tool.rating))
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(RPTheme.white)
                    Text("(\(tool.reviewCount))")
                        .font(.system(size: 10))
                        .foregroundStyle(RPTheme.gray)
                }

                Text(tool.pricePerDay)
                    .font(RPFont.mono(13, weight: .semibold))
                    .foregroundStyle(RPTheme.gold)
                + Text(" /jour")
                    .font(RPFont.body(10))
                    .foregroundStyle(RPTheme.gray)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
        }
        .background(RPTheme.dark)
        .overlay(
            RoundedRectangle(cornerRadius: RPTheme.cardRadius)
                .stroke(RPTheme.border, lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
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
