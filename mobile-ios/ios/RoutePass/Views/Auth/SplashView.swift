import SwiftUI

/// Splash ROUTEPASS — fond noir luxe, monogramme R or et wordmark, fade-in
/// avec une lueur dorée qui pulse en arrière-plan.
struct SplashView: View {
    @State private var logoScale: CGFloat = 0.85
    @State private var logoOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var glowOpacity: Double = 0

    let onFinished: () -> Void

    var body: some View {
        ZStack {
            RPTheme.black.ignoresSafeArea()

            // Halo or pulsant en arrière-plan
            Circle()
                .fill(
                    RadialGradient(
                        colors: [RPTheme.gold.opacity(0.18), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 220
                    )
                )
                .frame(width: 460, height: 460)
                .opacity(glowOpacity)

            VStack(spacing: 18) {
                // Monogramme R or italique
                Text("R")
                    .font(RPFont.display(96))
                    .foregroundStyle(RPTheme.goldGradient)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                VStack(spacing: 6) {
                    Text("ROUTEPASS")
                        .font(.system(size: 16, weight: .semibold))
                        .tracking(8)
                        .foregroundStyle(RPTheme.gold)

                    Text("Premium Services")
                        .font(RPFont.displayItalic(13))
                        .foregroundStyle(RPTheme.gray)
                }
                .opacity(subtitleOpacity)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 1.4)) {
                glowOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                subtitleOpacity = 1.0
            }

            Task {
                try? await Task.sleep(for: .seconds(1.6))
                onFinished()
            }
        }
    }
}
