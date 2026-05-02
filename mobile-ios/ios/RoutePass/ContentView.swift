import SwiftUI

/// Conteneur principal post-auth.
///
/// Architecture épurée — 4 onglets + FAB Scan central :
///   0. Accueil
///   1. Découvrir   (regroupe Transport / Location / Outils / Immobilier
///                   via un sélecteur de catégorie en haut de la page)
///   2. [FAB Scan]  (toujours visible au centre du dock)
///   3. Carte
///   4. Compte
///
/// Le FAB ouvre QRScannerView en fullscreen depuis n'importe quel onglet.
struct ContentView: View {
    @State private var currentPage: Int = 0
    @State private var hapticTrigger: Int = 0
    @State private var showScanner: Bool = false

    private let leftPages: [TabSpec] = [
        .init(id: 0, label: "Accueil",   icon: "house.fill"),
        .init(id: 1, label: "Découvrir", icon: "sparkles"),
    ]

    private let rightPages: [TabSpec] = [
        .init(id: 2, label: "Carte",   icon: "map.fill"),
        .init(id: 3, label: "Compte",  icon: "person.fill"),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentPage) {
                AccueilView().tag(0)
                DecouvrirView().tag(1)
                MapTabView().tag(2)
                CompteView().tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)
            .onChange(of: currentPage) { _, _ in hapticTrigger += 1 }
            .sensoryFeedback(.selection, trigger: hapticTrigger)
            .task {
                LocationManager.shared.requestAuthorization()
            }
            .onReceive(NotificationCenter.default.publisher(for: .rpJumpToTab)) { note in
                if let target = note.object as? Int, (0...3).contains(target) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        currentPage = target
                    }
                    hapticTrigger += 1
                }
            }

            bottomDock
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
        }
        .background(RPTheme.black)
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $showScanner) {
            QRScannerView(
                onDetected: { showScanner = false },
                onDismiss: { showScanner = false }
            )
        }
    }

    // MARK: - Dock

    private var bottomDock: some View {
        HStack(spacing: 0) {
            ForEach(leftPages) { page in
                tabButton(page: page)
            }

            scanFAB

            ForEach(rightPages) { page in
                tabButton(page: page)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 6)
        .padding(.bottom, 6)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(RPTheme.dark.opacity(0.85))
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(RPTheme.border, lineWidth: 1)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .rpCardShadow()
    }

    private var scanFAB: some View {
        Button {
            hapticTrigger += 1
            showScanner = true
        } label: {
            ZStack {
                Circle()
                    .fill(RPTheme.goldGradient)
                    .frame(width: 60, height: 60)
                    .shadow(color: RPTheme.gold.opacity(0.5), radius: 16, y: 4)
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(RPTheme.black)
            }
        }
        .buttonStyle(.plain)
        .offset(y: -18) // surélève le FAB au-dessus du dock
        .frame(maxWidth: .infinity)
        .sensoryFeedback(.impact(weight: .medium), trigger: hapticTrigger)
    }

    private func tabButton(page: TabSpec) -> some View {
        let isActive = currentPage == page.id
        return Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentPage = page.id
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: page.icon)
                    .font(.system(size: isActive ? 19 : 17, weight: .medium))
                    .foregroundStyle(isActive ? RPTheme.gold : RPTheme.gray)
                    .symbolEffect(.bounce, value: isActive ? hapticTrigger : 0)

                Text(page.label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(isActive ? RPTheme.gold : RPTheme.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct TabSpec: Identifiable {
    let id: Int
    let label: String
    let icon: String
}
