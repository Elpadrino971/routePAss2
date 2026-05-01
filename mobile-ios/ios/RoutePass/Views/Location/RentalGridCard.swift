import SwiftUI

struct RentalGridCard: View {
    let item: RentalItem
    @State private var appeared: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color(RPTheme.accent.opacity(0.06))
                .frame(height: 130)
                .overlay {
                    VStack(spacing: RPTheme.Spacing.sm) {
                        Image(systemName: item.icon)
                            .font(.system(size: 30))
                            .foregroundStyle(RPTheme.accent.opacity(0.45))
                        HStack(spacing: 4) {
                            ForEach(item.features.prefix(2), id: \.self) { feat in
                                Text(feat)
                                    .font(.system(.caption2, design: .default, weight: .medium))
                                    .foregroundStyle(RPTheme.textSecondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(.systemBackground).opacity(0.8))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .allowsHitTesting(false)
                }
                .clipShape(.rect(cornerRadius: 14))
                .overlay(alignment: .topLeading) {
                    RPBadge(status: item.status)
                        .scaleEffect(0.8)
                        .padding(6)
                }

            VStack(alignment: .leading, spacing: RPTheme.Spacing.xs) {
                Text(item.name)
                    .font(.system(.subheadline, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    if item.ownerVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(RPTheme.accent)
                    }
                    Text(item.ownerName)
                        .font(.system(.caption2, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                        .lineLimit(1)
                }

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.orange)
                    Text(String(format: "%.1f", item.rating))
                        .font(.system(.caption2, design: .default, weight: .semibold))
                    Text("(\(item.reviewCount))")
                        .font(.system(.caption2, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                }

                Text(item.pricePerDay)
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .foregroundStyle(RPTheme.accent)
                + Text(" /jour")
                    .font(.system(.caption2, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, RPTheme.Spacing.sm)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        .shadow(color: RPTheme.cardShadow, radius: 6, x: 0, y: 2)
        .scaleEffect(appeared ? 1 : 0.95)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
}
