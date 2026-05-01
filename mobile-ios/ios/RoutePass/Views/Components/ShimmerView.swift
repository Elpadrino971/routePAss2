import SwiftUI

struct ShimmerView: View {
    @State private var phase: CGFloat = -200

    var body: some View {
        Color(.tertiarySystemFill)
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.25), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
            )
            .clipShape(.rect(cornerRadius: 12))
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 400
                }
            }
    }
}

struct ShimmerCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.sm) {
            ShimmerView()
                .frame(height: 160)

            ShimmerView()
                .frame(height: 16)
                .frame(maxWidth: 180)

            ShimmerView()
                .frame(height: 12)
                .frame(maxWidth: 120)

            ShimmerView()
                .frame(height: 20)
                .frame(maxWidth: 80)
        }
        .padding(RPTheme.Spacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
    }
}
