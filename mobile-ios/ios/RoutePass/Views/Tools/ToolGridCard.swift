import SwiftUI

struct ToolGridCard: View {
    let tool: ToolItem
    @State private var appeared: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color(RPTheme.accent.opacity(0.06))
                .frame(height: 130)
                .overlay {
                    VStack(spacing: RPTheme.Spacing.sm) {
                        Image(systemName: tool.icon)
                            .font(.system(size: 30))
                            .foregroundStyle(RPTheme.accent.opacity(0.45))
                        HStack(spacing: 4) {
                            Text(tool.condition.rawValue)
                                .font(.system(.caption2, design: .default, weight: .medium))
                                .foregroundStyle(tool.condition.color)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(tool.condition.color.opacity(0.12))
                                .clipShape(Capsule())
                            if tool.deliveryAvailable {
                                Image(systemName: "shippingbox.fill")
                                    .font(.system(size: 9))
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
                    RPBadge(status: tool.status)
                        .scaleEffect(0.8)
                        .padding(6)
                }

            VStack(alignment: .leading, spacing: RPTheme.Spacing.xs) {
                Text(tool.name)
                    .font(.system(.subheadline, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)
                    .lineLimit(1)

                Text("\(tool.brand) · \(tool.model)")
                    .font(.system(.caption2, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.orange)
                    Text(String(format: "%.1f", tool.rating))
                        .font(.system(.caption2, design: .default, weight: .semibold))
                    Text("(\(tool.reviewCount))")
                        .font(.system(.caption2, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                }

                Text(tool.pricePerDay)
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
