import SwiftUI

struct ToolCategoryCard: View {
    let category: ToolCategory
    let isSelected: Bool
    @State private var appeared: Bool = false

    var body: some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            Text(category.emoji)
                .font(.system(size: 28))
                .frame(width: 60, height: 60)
                .background(isSelected ? RPTheme.accent.opacity(0.15) : Color(.tertiarySystemFill))
                .clipShape(.rect(cornerRadius: 16))

            Text(category.rawValue)
                .font(.system(.caption, design: .default, weight: .semibold))
                .foregroundStyle(isSelected ? RPTheme.accent : RPTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text("\(category.itemCount)")
                .font(.system(.caption2, design: .default))
                .foregroundStyle(RPTheme.textSecondary)
        }
        .frame(width: 76)
        .scaleEffect(appeared ? 1 : 0.9)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
}
