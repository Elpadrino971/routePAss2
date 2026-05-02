import SwiftUI

/// Tuile catégorie horizontale Location — emoji sur tuile dark luxury,
/// label, count.
struct RentalCategoryCard: View {
    let category: RentalCategory
    let isSelected: Bool
    @State private var appeared: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(RPTheme.goldGradient) : AnyShapeStyle(RPTheme.dark))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isSelected ? Color.clear : RPTheme.border, lineWidth: 1)
                    )

                Text(category.emoji)
                    .font(.system(size: 28))
            }
            .frame(width: 60, height: 60)

            Text(category.rawValue)
                .font(RPFont.body(11, weight: .semibold))
                .foregroundStyle(isSelected ? RPTheme.gold : RPTheme.white)

            Text("\(category.itemCount) biens")
                .font(.system(size: 9))
                .foregroundStyle(RPTheme.gray)
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
