import SwiftUI

/// Accueil ROUTEPASS — reprend exactement le mockup iPhone 16 :
/// - Header "Bonjour, Richard" + avatar
/// - 4 quick actions en ligne (Me déplacer / Accéder / Scan / Bons)
/// - Section "En vedette" avec scroll horizontal + dots indicator
/// - Section "Récemment consultés" avec cards horizontales
struct AccueilView: View {
    @Environment(AppState.self) private var appState
    @State private var isLoading: Bool = true
    @State private var featuredIndex: Int = 0
    @State private var showScanner: Bool = false

    private var firstName: String {
        appState.userEmail.split(separator: "@").first.map(String.init)?.capitalized ?? "Richard"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: RPTheme.Spacing.lg) {
                header
                quickActionsRow
                featuredSection
                recentSection
            }
            .padding(.top, 12)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background(RPTheme.black.ignoresSafeArea())
        .fullScreenCover(isPresented: $showScanner) {
            QRScannerView(
                onDetected: { showScanner = false },
                onDismiss: { showScanner = false }
            )
        }
        .task {
            try? await Task.sleep(for: .seconds(0.8))
            withAnimation(.spring(response: 0.4)) {
                isLoading = false
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Bonjour ,")
                    .font(RPFont.body(13))
                    .foregroundStyle(RPTheme.gray)
                Text(firstName)
                    .font(RPFont.display(28))
                    .foregroundStyle(RPTheme.white)
            }
            Spacer()
            avatarButton
        }
        .padding(.horizontal, RPTheme.Spacing.lg)
    }

    private var avatarButton: some View {
        ZStack {
            Circle()
                .fill(RPTheme.dark)
                .overlay(Circle().stroke(RPTheme.gold.opacity(0.4), lineWidth: 1))
                .frame(width: 38, height: 38)
            Image(systemName: "person.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(RPTheme.gold)
        }
    }

    // MARK: - Quick actions

    private var quickActionsRow: some View {
        HStack(spacing: 12) {
            RPQuickActionTile(icon: "car.fill", label: "Me déplacer") {
                NotificationCenter.default.post(name: .rpJumpToTab, object: 1) // Découvrir → Transport
            }
            RPQuickActionTile(icon: "key.fill", label: "Accéder", isHighlighted: true) {
                NotificationCenter.default.post(name: .rpJumpToTab, object: 1) // Découvrir → Location
            }
            RPQuickActionTile(icon: "qrcode.viewfinder", label: "Scan") {
                showScanner = true
            }
            RPQuickActionTile(icon: "map.fill", label: "Carte") {
                NotificationCenter.default.post(name: .rpJumpToTab, object: 2) // Carte
            }
        }
        .padding(.horizontal, RPTheme.Spacing.lg)
    }

    // MARK: - En vedette

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("En vedette")
                    .font(RPFont.display(20))
                    .foregroundStyle(RPTheme.white)
                Spacer()
                Button("Tout voir") {}
                    .font(RPFont.body(12, weight: .medium))
                    .foregroundStyle(RPTheme.gold)
            }
            .padding(.horizontal, RPTheme.Spacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(MockData.featuredItems) { item in
                        Button {
                            NotificationCenter.default.post(name: .rpJumpToTab, object: 1)
                        } label: {
                            RPFeaturedCard(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, RPTheme.Spacing.lg)
            }

            HStack(spacing: 5) {
                ForEach(MockData.featuredItems.indices, id: \.self) { i in
                    Capsule()
                        .fill(i == featuredIndex ? RPTheme.gold : RPTheme.border)
                        .frame(width: i == featuredIndex ? 16 : 5, height: 5)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Récemment consultés

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Récemment consultés")
                    .font(RPFont.display(20))
                    .foregroundStyle(RPTheme.white)
                Spacer()
            }
            .padding(.horizontal, RPTheme.Spacing.lg)

            VStack(spacing: 10) {
                if isLoading {
                    ForEach(0..<2, id: \.self) { _ in
                        ShimmerCardView()
                    }
                } else {
                    ForEach(MockData.recentItems) { item in
                        Button {
                            NotificationCenter.default.post(name: .rpJumpToTab, object: 1)
                        } label: {
                            RPCard(item: item)
                        }
                        .buttonStyle(.plain)
                        .sensoryFeedback(.impact(flexibility: .soft), trigger: item.id)
                    }
                }
            }
            .padding(.horizontal, RPTheme.Spacing.lg)
        }
    }
}
