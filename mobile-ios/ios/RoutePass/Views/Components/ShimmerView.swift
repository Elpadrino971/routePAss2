import SwiftUI

/// Shimmer placeholder dark luxury — surface dark2 traversée par un flash or.
struct ShimmerView: View {
    @State private var phase: CGFloat = -250

    var body: some View {
        RPTheme.dark2
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        RPTheme.gold.opacity(0.18),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
            )
            .clipShape(.rect(cornerRadius: 12))
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 500
                }
            }
    }
}

/// Skeleton de card horizontal (matching RPCard).
struct ShimmerCardView: View {
    var body: some View {
        HStack(spacing: 0) {
            ShimmerView()
                .frame(width: 130, height: 110)

            VStack(alignment: .leading, spacing: 8) {
                ShimmerView().frame(height: 14).frame(maxWidth: 160)
                ShimmerView().frame(height: 10).frame(maxWidth: 110)
                Spacer()
                ShimmerView().frame(height: 14).frame(maxWidth: 80)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
        }
        .background(RPTheme.dark)
        .overlay(
            RoundedRectangle(cornerRadius: RPTheme.cardRadius)
                .stroke(RPTheme.border, lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
    }
}
