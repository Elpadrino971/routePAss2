import SwiftUI

/// Onboarding ROUTEPASS — 3 slides plein écran qui reprennent EXACTEMENT les
/// maquettes iPhone 16 fournies dans le master prompt :
///   1. « Payez, montez, partez »
///   2. « Louez sans, contact »
///   3. « Vos actifs, travaillent pour vous »
///
/// Chaque slide affiche une hero image plein écran (voiture devant un palace,
/// Mercedes éclairée la nuit, villa au coucher du soleil), un divider « R » or
/// italique, et le bouton « Suivant » / « Commencer » or en bas.
struct OnboardingView: View {
    @State private var currentPage: Int = 0
    @State private var showRoleSheet: Bool = false

    let onComplete: (UserRole) -> Void

    private let slides: [OnboardingSlide] = [
        OnboardingSlide(
            imageURL: "https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1200&q=80",
            titleStart: "Payez, montez,",
            titleAccent: "partez",
            subtitle: "Scannez, réservez et accédez à vos transports et locations en quelques secondes."
        ),
        OnboardingSlide(
            imageURL: "https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=1200&q=80",
            titleStart: "Louez sans,",
            titleAccent: "contact",
            subtitle: "Véhicules, bateaux, appartements. Disponibilité en temps réel, accès autonome."
        ),
        OnboardingSlide(
            imageURL: "https://images.unsplash.com/photo-1613977257363-707ba9348227?auto=format&fit=crop&w=1200&q=80",
            titleStart: "Vos actifs,",
            titleAccent: "travaillent pour vous",
            subtitle: "Mettez vos biens en location. Recevez vos paiements automatiquement."
        ),
    ]

    var body: some View {
        ZStack {
            RPTheme.black.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(slides.indices, id: \.self) { index in
                        slideContent(slide: slides[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea(edges: .top)

                bottomSection
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showRoleSheet) {
            RoleSelectionView(onRoleSelected: { role in
                showRoleSheet = false
                onComplete(role)
            })
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(24)
            .presentationBackground(RPTheme.dark)
        }
    }

    // MARK: - Slide content

    @ViewBuilder
    private func slideContent(slide: OnboardingSlide) -> some View {
        VStack(spacing: 0) {
            heroImage(url: slide.imageURL)
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.62)
                .overlay(alignment: .top) {
                    monogramHeader
                        .padding(.top, 56)
                }

            VStack(spacing: RPTheme.Spacing.md) {
                titleBlock(start: slide.titleStart, accent: slide.titleAccent)
                rDivider
                Text(slide.subtitle)
                    .font(RPFont.body(14))
                    .foregroundStyle(RPTheme.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, RPTheme.Spacing.xl)
            }
            .padding(.top, RPTheme.Spacing.lg)

            Spacer(minLength: 0)
        }
    }

    private func heroImage(url: String) -> some View {
        ZStack {
            AsyncImage(url: URL(string: url)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .empty:
                    RPTheme.dark2
                case .failure:
                    RPTheme.dark2
                @unknown default:
                    RPTheme.dark2
                }
            }
            .clipped()

            // Vignette dégradée du noir vers transparent (en bas)
            LinearGradient(
                colors: [RPTheme.black.opacity(0.0), RPTheme.black.opacity(0.4), RPTheme.black],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var monogramHeader: some View {
        VStack(spacing: 2) {
            Text("R")
                .font(RPFont.display(36))
                .foregroundStyle(RPTheme.goldGradient)
            Text("ROUTEPASS")
                .font(.system(size: 9, weight: .semibold))
                .tracking(4)
                .foregroundStyle(RPTheme.gold)
        }
    }

    private func titleBlock(start: String, accent: String) -> some View {
        // Titre avec une partie "italique or" (cf. mockups : "Payez, montez, *partez*")
        (
            Text(start + " ")
                .foregroundStyle(RPTheme.white)
            +
            Text(accent)
                .foregroundStyle(RPTheme.gold)
                .italic()
        )
        .font(RPFont.display(30))
        .multilineTextAlignment(.center)
        .padding(.horizontal, RPTheme.Spacing.lg)
    }

    /// Divider « R » or au centre, deux lignes fines or sur les côtés.
    private var rDivider: some View {
        HStack(spacing: 12) {
            line
            Text("R")
                .font(RPFont.displayItalic(16))
                .foregroundStyle(RPTheme.gold)
            line
        }
        .frame(width: 120)
    }

    private var line: some View {
        LinearGradient(
            colors: [RPTheme.gold.opacity(0), RPTheme.gold.opacity(0.6), RPTheme.gold.opacity(0)],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 1)
    }

    // MARK: - Bottom

    private var bottomSection: some View {
        VStack(spacing: RPTheme.Spacing.md) {
            // Dots
            HStack(spacing: 6) {
                ForEach(slides.indices, id: \.self) { i in
                    Capsule()
                        .fill(i == currentPage ? RPTheme.gold : RPTheme.border)
                        .frame(width: i == currentPage ? 22 : 6, height: 6)
                        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: currentPage)
                }
            }
            .padding(.bottom, 4)

            Button(action: advance) {
                Text(isLast ? "Commencer" : "Suivant")
            }
            .buttonStyle(RPPrimaryButtonStyle(size: .lg))
            .padding(.horizontal, RPTheme.Spacing.xl)

            if !isLast {
                Button("Passer") {
                    showRoleSheet = true
                }
                .buttonStyle(RPGhostButtonStyle())
            }
        }
        .padding(.top, RPTheme.Spacing.md)
        .padding(.bottom, RPTheme.Spacing.xl)
    }

    private var isLast: Bool { currentPage == slides.count - 1 }

    private func advance() {
        if isLast {
            showRoleSheet = true
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentPage += 1
            }
        }
    }
}

private struct OnboardingSlide {
    let imageURL: String
    let titleStart: String
    let titleAccent: String
    let subtitle: String
}
