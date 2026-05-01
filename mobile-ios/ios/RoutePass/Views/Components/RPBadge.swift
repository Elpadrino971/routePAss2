import SwiftUI

/// Badge ROUTEPASS — capsule colorée avec point pulsant optionnel.
/// Utilisable sur fond dark luxury comme sur fond clair (s'adapte).
struct RPBadge: View {
    let status: RPStatus
    var compact: Bool = false
    var pulse: Bool = true

    var body: some View {
        HStack(spacing: 6) {
            if pulse && status == .disponible {
                PulsingDot(color: status.color)
            } else {
                Image(systemName: status.icon)
                    .font(.system(size: compact ? 9 : 10, weight: .semibold))
            }
            Text(status.rawValue)
                .font(.system(size: compact ? 10 : 11, weight: .semibold))
                .tracking(0.2)
        }
        .foregroundStyle(status.color)
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 4 : 5)
        .background(
            Capsule()
                .fill(status.color.opacity(0.15))
                .overlay(Capsule().stroke(status.color.opacity(0.3), lineWidth: 0.5))
        )
    }
}

/// Petit cercle pulsant (utilisé dans les badges "Disponible" et sur les listes).
struct PulsingDot: View {
    var color: Color = RPTheme.success
    var size: CGFloat = 7
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .scaleEffect(pulse ? 1.6 : 1)
                .opacity(pulse ? 0 : 0.6)
            Circle()
                .fill(color)
                .frame(width: size, height: size)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: false)) {
                pulse = true
            }
        }
    }
}

/// Badge custom (texte arbitraire) — pour "Principal", "Premium", "Nouveau", etc.
struct RPTagBadge: View {
    let text: String
    var color: Color = RPTheme.danger

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(color)
            )
    }
}
