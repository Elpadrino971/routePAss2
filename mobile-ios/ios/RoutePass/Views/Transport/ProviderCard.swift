import SwiftUI

/// Card prestataire transport — avatar Unsplash + verified, nom, type+distance,
/// étoiles, prix or, dot pulsant Disponible. Aligné dark luxury.
struct ProviderCard: View {
    let provider: Provider
    @State private var appeared: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            avatarView

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(provider.name)
                        .font(RPFont.body(14, weight: .semibold))
                        .foregroundStyle(RPTheme.white)
                        .lineLimit(1)

                    if provider.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(RPTheme.success)
                    }
                }

                Text(provider.vehicleType)
                    .font(RPFont.body(11))
                    .foregroundStyle(RPTheme.gray)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(RPTheme.warning)
                    Text(String(format: "%.1f", provider.rating))
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(RPTheme.white)
                    Text("(\(provider.reviewCount))")
                        .font(.system(size: 10))
                        .foregroundStyle(RPTheme.gray)
                    if let km = provider.distanceKm {
                        Text("· \(String(format: "%.1f", km)) km")
                            .font(.system(size: 10))
                            .foregroundStyle(RPTheme.gray)
                    }
                }
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 6) {
                Text(provider.tarif)
                    .font(RPFont.mono(15, weight: .semibold))
                    .foregroundStyle(RPTheme.gold)

                if provider.status == .disponible {
                    HStack(spacing: 4) {
                        PulsingDot(color: RPTheme.success, size: 6)
                        Text("Disponible")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(RPTheme.success)
                    }
                } else {
                    RPBadge(status: provider.status, compact: true)
                }
            }
        }
        .padding(12)
        .background(RPTheme.dark)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(RPTheme.border, lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: 16))
        .scaleEffect(appeared ? 1 : 0.97)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    private var avatarView: some View {
        ZStack {
            RPImage(url: provider.avatarURL, fallback: provider.avatarSystemName)
                .frame(width: 46, height: 46)
                .clipShape(Circle())
            Circle()
                .stroke(RPTheme.border, lineWidth: 1)
                .frame(width: 46, height: 46)
        }
    }
}
