import SwiftUI

/// Ligne prestataire pour la page Transport — avatar circulaire avec badge
/// vérifié, nom, type+distance, étoiles+nb avis, prix, "Disponible" point vert.
struct RPProviderRow: View {
    let provider: RPProvider
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                avatar

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(provider.name)
                            .font(RPFont.body(14, weight: .semibold))
                            .foregroundStyle(RPTheme.white)
                        if provider.verified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(RPTheme.success)
                        }
                    }

                    Text(provider.subtitle)
                        .font(RPFont.body(11))
                        .foregroundStyle(RPTheme.gray)
                        .lineLimit(1)

                    RPRatingStars(rating: provider.rating, reviewsCount: provider.reviewsCount, distanceKm: provider.distanceKm)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(provider.priceLabel)
                        .font(RPFont.mono(15, weight: .semibold))
                        .foregroundStyle(RPTheme.gold)

                    HStack(spacing: 4) {
                        PulsingDot(color: RPTheme.success, size: 6)
                        Text("Disponible")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(RPTheme.success)
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
        }
        .buttonStyle(.plain)
    }

    private var avatar: some View {
        ZStack {
            RPImage(url: provider.avatarURL, fallback: "person.fill")
                .frame(width: 46, height: 46)
                .clipShape(Circle())

            Circle()
                .stroke(RPTheme.border, lineWidth: 1)
                .frame(width: 46, height: 46)
        }
    }
}

/// Étoiles + note + nombre d'avis + distance.
struct RPRatingStars: View {
    let rating: Double
    let reviewsCount: Int
    var distanceKm: Double? = nil

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: 9))
                .foregroundStyle(RPTheme.warning)
            Text(String(format: "%.1f", rating))
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(RPTheme.white)
            Text("(\(reviewsCount))")
                .font(.system(size: 10))
                .foregroundStyle(RPTheme.gray)
            if let distanceKm {
                Text("· \(String(format: "%.1f", distanceKm)) km")
                    .font(.system(size: 10))
                    .foregroundStyle(RPTheme.gray)
            }
        }
    }
}

// MARK: - Modèle simple pour les rows

nonisolated struct RPProvider: Identifiable, Sendable {
    let id: String
    let name: String
    let subtitle: String          // "Berline · Paris" | "Yacht · Cannes"
    let avatarURL: String?
    let verified: Bool
    let rating: Double            // 0…5
    let reviewsCount: Int
    let distanceKm: Double?
    let priceLabel: String        // "85€/h" | "12€"

    static let mock: [RPProvider] = [
        .init(id: "p1", name: "Laurent Dupont",  subtitle: "Toyota Corolla · Taxi",     avatarURL: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80", verified: true,  rating: 4.8, reviewsCount: 342, distanceKm: 0.8, priceLabel: "12€"),
        .init(id: "p2", name: "Philippe Martin", subtitle: "Mercedes Sprinter · Minibus", avatarURL: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80", verified: true, rating: 4.6, reviewsCount: 128, distanceKm: 1.2, priceLabel: "18€"),
        .init(id: "p3", name: "Nicolas Lefèbvre", subtitle: "Hyundai Accent · Taxi",       avatarURL: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=200&q=80", verified: true, rating: 4.9, reviewsCount: 540, distanceKm: 0.4, priceLabel: "10€"),
        .init(id: "p4", name: "Marc Fontaine",   subtitle: "Mercedes V-Class · Berline",  avatarURL: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80", verified: true, rating: 4.7, reviewsCount: 211, distanceKm: 3.1, priceLabel: "35€"),
    ]
}
