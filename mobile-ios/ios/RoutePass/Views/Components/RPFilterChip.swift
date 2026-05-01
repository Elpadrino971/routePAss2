import SwiftUI

/// Chip filtre dorée — utilisée pour les filtres "Tous / Disponible / Meilleure note / Plus proche".
struct RPFilterChip: View {
    let label: String
    let isActive: Bool
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(RPFont.body(12, weight: .semibold))
                .foregroundStyle(isActive ? RPTheme.black : RPTheme.gray)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isActive ? RPTheme.goldGradient : LinearGradient(colors: [RPTheme.dark, RPTheme.dark], startPoint: .leading, endPoint: .trailing))
                )
                .overlay(
                    Capsule()
                        .stroke(isActive ? Color.clear : RPTheme.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .animation(.snappy(duration: 0.18), value: isActive)
    }
}
