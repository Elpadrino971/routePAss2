import SwiftUI

struct RPFeaturedCard: View {
    let item: RPCardItem
    @State private var appeared: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.sm) {
            Color(RPTheme.accent.opacity(0.1))
                .frame(width: 260, height: 150)
                .overlay {
                    Image(systemName: item.imageName)
                        .font(.system(size: 36))
                        .foregroundStyle(RPTheme.accent.opacity(0.6))
                }
                .clipShape(.rect(cornerRadius: 14))
                .overlay(alignment: .topLeading) {
                    RPBadge(status: item.status)
                        .padding(RPTheme.Spacing.sm)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(.subheadline, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Text(item.subtitle)
                    .font(.system(.caption2, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
                    .lineLimit(1)
            }

            Text(item.price)
                .font(.system(.callout, design: .rounded, weight: .bold))
                .foregroundStyle(RPTheme.accent)
        }
        .frame(width: 260)
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        .shadow(color: RPTheme.cardShadow, radius: RPTheme.cardShadowRadius, x: 0, y: RPTheme.cardShadowY)
        .scaleEffect(appeared ? 1 : 0.95)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
}
