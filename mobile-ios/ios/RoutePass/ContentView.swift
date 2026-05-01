import SwiftUI

/// Conteneur principal post-auth.
///
/// Layout (mockup iPhone 16) :
///   - TabView swipe horizontal entre les 7 sections
///   - Dock or flottant avec 6 tabs + bouton Scan central surdimensionné (FAB)
///   - Le FAB Scan ouvre QRScannerView en fullscreen depuis n'importe quel onglet
///
/// Sections :
///   0. Accueil
///   1. Transport
///   2. Location
///   3. Outils
///   4. Immobilier
///   5. Carte
///   6. Compte
struct ContentView: View {
    @State private var currentPage: Int = 0
    @State private var hapticTrigger: Int = 0
    @State private var showScanner: Bool = false

    private let leftPages: [TabSpec] = [
        .init(id: 0, label: "Accueil",    icon: "house.fill"),
        .init(id: 1, label: "Transport",  icon: "car.fill"),
        .init(id: 2, label: "Location",   icon: "key.fill"),
    ]

    private let rightPages: [TabSpec] = [
        .init(id: 3, label: "Outils",     icon: "wrench.and.screwdriver.fill"),
        .init(id: 4, label: "Immobilier", icon: "building.2.fill"),
        .init(id: 5, label: "Carte",      icon: "map.fill"),
        .init(id: 6, label: "Compte",     icon: "person.fill"),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentPage) {
                AccueilView().tag(0)
                TransportView().tag(1)
                LocationView().tag(2)
                OutilsView().tag(3)
                ImmobilierView().tag(4)
                MapTabView().tag(5)
                CompteView().tag(6)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)
            .onChange(of: currentPage) { _, _ in hapticTrigger += 1 }
            .sensoryFeedback(.selection, trigger: hapticTrigger)
            .task {
                LocationManager.shared.requestAuthorization()
            }

            bottomDock
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
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
                    .frame(width: 56, height: 56)
                    .shadow(color: RPTheme.gold.opacity(0.5), radius: 14, y: 4)
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(RPTheme.black)
            }
        }
        .buttonStyle(.plain)
        .offset(y: -16) // surélève le FAB au-dessus du dock
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
            VStack(spacing: 3) {
                Image(systemName: page.icon)
                    .font(.system(size: isActive ? 17 : 15, weight: .medium))
                    .foregroundStyle(isActive ? RPTheme.gold : RPTheme.gray)
                    .symbolEffect(.bounce, value: isActive ? hapticTrigger : 0)
                if isActive {
                    Capsule()
                        .fill(RPTheme.gold)
                        .frame(width: 14, height: 2)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Capsule()
                        .fill(.clear)
                        .frame(height: 2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
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
