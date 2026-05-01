import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var shimmerOffset: CGFloat = -200

    let onFinished: () -> Void

    var body: some View {
        ZStack {
            RPTheme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(RPTheme.accent.opacity(0.08))
                        .frame(width: 120, height: 120)
                        .scaleEffect(logoScale * 1.1)

                    Text("R")
                        .font(.system(size: 64, weight: .bold, design: .default))
                        .foregroundStyle(RPTheme.accent)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                VStack(spacing: 4) {
                    Text("ROUTEPASS")
                        .font(.system(size: 22, weight: .bold, design: .default))
                        .tracking(6)
                        .foregroundStyle(RPTheme.textPrimary)

                    Text("Premium Services")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(RPTheme.textSecondary)
                }
                .opacity(subtitleOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }

            withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
                subtitleOpacity = 1.0
            }

            Task {
                try? await Task.sleep(for: .seconds(1.5))
                onFinished()
            }
        }
    }
}
