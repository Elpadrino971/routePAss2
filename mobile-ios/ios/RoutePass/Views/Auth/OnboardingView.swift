import SwiftUI

struct OnboardingView: View {
    @State private var currentPage: Int = 0
    @State private var appeared: Bool = false
    @State private var showRoleSheet: Bool = false

    let onComplete: (UserRole) -> Void

    private let slides: [OnboardingSlide] = [
        OnboardingSlide(
            emojis: ["🚕", "🚌", "🛥️", "🚛"],
            title: "Payez, montez, partez",
            subtitle: "Scannez le QR code de votre prestataire et payez en quelques secondes.",
            accentIcon: "qrcode.viewfinder",
            gradient: [Color.orange.opacity(0.1), RPTheme.accent.opacity(0.08)]
        ),
        OnboardingSlide(
            emojis: ["🔑", "📱", "✨", "🏎️"],
            title: "Louez sans contact",
            subtitle: "Véhicules, bateaux, appartements. Disponibilité en temps réel, accès autonome.",
            accentIcon: "key.fill",
            gradient: [Color.blue.opacity(0.1), RPTheme.accent.opacity(0.08)]
        ),
        OnboardingSlide(
            emojis: ["💰", "📈", "🏠", "⚡"],
            title: "Vos actifs travaillent pour vous",
            subtitle: "Mettez votre bien en location. Recevez vos paiements automatiquement.",
            accentIcon: "chart.line.uptrend.xyaxis",
            gradient: [Color.green.opacity(0.1), RPTheme.accent.opacity(0.08)]
        ),
    ]

    var body: some View {
        ZStack {
            RPTheme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(slides.enumerated()), id: \.offset) { index, slide in
                        slideContent(slide: slide, index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                bottomSection
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
        .sheet(isPresented: $showRoleSheet) {
            RoleSelectionView(onRoleSelected: { role in
                showRoleSheet = false
                onComplete(role)
            })
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(24)
        }
    }

    private func slideContent(slide: OnboardingSlide, index: Int) -> some View {
        VStack(spacing: RPTheme.Spacing.xl) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(
                        LinearGradient(
                            colors: slide.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 240, height: 240)

                Image(systemName: slide.accentIcon)
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(RPTheme.accent.opacity(0.15))
                    .offset(x: 60, y: -60)

                floatingEmojis(slide.emojis, index: index)
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.85)

            VStack(spacing: RPTheme.Spacing.md) {
                Text(slide.title)
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundStyle(RPTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text(slide.subtitle)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, RPTheme.Spacing.xl)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)

            Spacer()
            Spacer()
        }
    }

    private func floatingEmojis(_ emojis: [String], index: Int) -> some View {
        let positions: [(x: CGFloat, y: CGFloat)] = [
            (-70, -70), (70, -50), (-50, 60), (80, 70)
        ]
        return ZStack {
            ForEach(Array(emojis.enumerated()), id: \.offset) { i, emoji in
                Text(emoji)
                    .font(.system(size: 40))
                    .offset(x: positions[i].x, y: positions[i].y)
                    .rotationEffect(.degrees(Double(i) * 8 - 12))
            }
        }
    }

    private var bottomSection: some View {
        VStack(spacing: RPTheme.Spacing.lg) {
            HStack(spacing: 8) {
                ForEach(0..<slides.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? RPTheme.accent : RPTheme.textSecondary.opacity(0.2))
                        .frame(width: index == currentPage ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: currentPage)
                }
            }

            if currentPage == slides.count - 1 {
                Button {
                    showRoleSheet = true
                } label: {
                    Text("Commencer")
                }
                .buttonStyle(RPPrimaryButtonStyle())
                .padding(.horizontal, RPTheme.Spacing.xl)
                .transition(.scale.combined(with: .opacity))
            } else {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        currentPage += 1
                    }
                } label: {
                    Text("Suivant")
                }
                .buttonStyle(RPSecondaryButtonStyle())
                .padding(.horizontal, RPTheme.Spacing.xl)
                .transition(.scale.combined(with: .opacity))
            }

            Button {
                if currentPage < slides.count - 1 {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        currentPage = slides.count - 1
                    }
                } else {
                    showRoleSheet = true
                }
            } label: {
                Text("Passer")
            }
            .buttonStyle(RPGhostButtonStyle())
        }
        .padding(.bottom, RPTheme.Spacing.xl)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentPage)
    }
}

private struct OnboardingSlide {
    let emojis: [String]
    let title: String
    let subtitle: String
    let accentIcon: String
    let gradient: [Color]
}
