import SwiftUI

struct ProviderCard: View {
    let provider: Provider
    @State private var appeared: Bool = false

    var body: some View {
        HStack(spacing: RPTheme.Spacing.md) {
            avatarView

            VStack(alignment: .leading, spacing: RPTheme.Spacing.xs) {
                HStack(spacing: 6) {
                    Text(provider.name)
                        .font(.system(.subheadline, design: .default, weight: .semibold))
                        .foregroundStyle(RPTheme.textPrimary)
                        .lineLimit(1)

                    if provider.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption2)
                            .foregroundStyle(RPTheme.accent)
                    }
                }

                Text(provider.vehicleType)
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
                    .lineLimit(1)

                HStack(spacing: RPTheme.Spacing.sm) {
                    ratingView
                    if let km = provider.distanceKm {
                        Text("·")
                            .foregroundStyle(RPTheme.textSecondary)
                        Label(String(format: "%.1f km", km), systemImage: "location.fill")
                            .font(.system(.caption2, design: .default))
                            .foregroundStyle(RPTheme.textSecondary)
                    }
                }
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: RPTheme.Spacing.sm) {
                Text(provider.tarif)
                    .font(.system(.callout, design: .rounded, weight: .bold))
                    .foregroundStyle(RPTheme.accent)

                RPBadge(status: provider.status)
            }
        }
        .padding(RPTheme.Spacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        .shadow(color: RPTheme.cardShadow, radius: 6, x: 0, y: 2)
        .scaleEffect(appeared ? 1 : 0.97)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    private var avatarView: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: provider.avatarSystemName)
                .font(.system(size: 36))
                .foregroundStyle(RPTheme.accent.opacity(0.7))
                .frame(width: 56, height: 56)
                .background(RPTheme.accent.opacity(0.1))
                .clipShape(Circle())

            if provider.isVerified {
                Circle()
                    .fill(RPTheme.accent)
                    .frame(width: 16, height: 16)
                    .overlay {
                        Image(systemName: "checkmark")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .offset(x: 2, y: 2)
            }
        }
    }

    private var ratingView: some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill")
                .font(.caption2)
                .foregroundStyle(.orange)
            Text(String(format: "%.1f", provider.rating))
                .font(.system(.caption2, design: .default, weight: .semibold))
                .foregroundStyle(RPTheme.textPrimary)
            Text("(\(provider.reviewCount))")
                .font(.system(.caption2, design: .default))
                .foregroundStyle(RPTheme.textSecondary)
        }
    }
}
