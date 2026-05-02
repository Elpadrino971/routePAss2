import SwiftUI

/// Card grid Location — photo Unsplash en haut (130pt), titre + propriétaire
/// vérifié, étoiles, prix or, le tout en dark luxury.
struct RentalGridCard: View {
    let item: RentalItem
    @State private var appeared: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                RPImage(url: item.gallery.first, fallback: item.icon)
                    .frame(height: 130)

                LinearGradient(
                    colors: [.black.opacity(0), .black.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 130)

                RPBadge(status: item.status, compact: true)
                    .padding(8)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(item.name)
                    .font(RPFont.body(13, weight: .semibold))
                    .foregroundStyle(RPTheme.white)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    if item.ownerVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(RPTheme.success)
                    }
                    Text(item.ownerName)
                        .font(RPFont.body(10))
                        .foregroundStyle(RPTheme.gray)
                        .lineLimit(1)
                }

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(RPTheme.warning)
                    Text(String(format: "%.1f", item.rating))
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(RPTheme.white)
                    Text("(\(item.reviewCount))")
                        .font(.system(size: 10))
                        .foregroundStyle(RPTheme.gray)
                }

                Text(item.pricePerDay)
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
