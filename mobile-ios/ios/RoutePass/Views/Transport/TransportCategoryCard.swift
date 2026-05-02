import SwiftUI

/// Tuile catégorie horizontale Transport — emoji sur tuile dark luxury, label, count.
struct TransportCategoryCard: View {
    let category: TransportCategory
    let isSelected: Bool
    @State private var appeared: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(RPTheme.goldGradient) : AnyShapeStyle(RPTheme.dark))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(isSelected ? Color.clear : RPTheme.border, lineWidth: 1)
                    )
                Text(category.emoji)
                    .font(.system(size: 30))
            }
            .frame(width: 64, height: 64)

            Text(category.name)
                .font(RPFont.body(12, weight: .semibold))
                .foregroundStyle(isSelected ? RPTheme.gold : RPTheme.white)

            Text("\(category.providerCount) dispo")
                .font(.system(size: 9))
                .foregroundStyle(RPTheme.gray)
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
