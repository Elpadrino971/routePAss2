import SwiftUI

struct TransportCategoryCard: View {
    let category: TransportCategory
    let isSelected: Bool
    @State private var appeared: Bool = false

    var body: some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            Text(category.emoji)
                .font(.system(size: 32))
                .frame(width: 64, height: 64)
                .background(isSelected ? RPTheme.accent.opacity(0.15) : Color(.tertiarySystemFill))
                .clipShape(.rect(cornerRadius: 18))

            Text(category.name)
                .font(.system(.caption, design: .default, weight: .semibold))
                .foregroundStyle(isSelected ? RPTheme.accent : RPTheme.textPrimary)

            Text("\(category.providerCount) dispo")
                .font(.system(.caption2, design: .default))
                .foregroundStyle(RPTheme.textSecondary)
        }
        .frame(width: 80)
        .scaleEffect(appeared ? 1 : 0.9)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
}
