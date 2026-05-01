import SwiftUI

struct RPCard: View {
    let item: RPCardItem
    @State private var appeared: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.sm) {
            Color(RPTheme.accent.opacity(0.08))
                .frame(height: 160)
                .overlay {
                    Image(systemName: item.imageName)
                        .font(.system(size: 40))
                        .foregroundStyle(RPTheme.accent.opacity(0.5))
                }
                .clipShape(.rect(cornerRadius: 16))
                .overlay(alignment: .topTrailing) {
                    RPBadge(status: item.status)
                        .padding(RPTheme.Spacing.sm)
                }

            VStack(alignment: .leading, spacing: RPTheme.Spacing.xs) {
                Text(item.title)
                    .font(.system(.headline, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Text(item.subtitle)
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
                    .lineLimit(1)
            }

            Text(item.price)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(RPTheme.accent)
        }
        .padding(RPTheme.Spacing.md)
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
