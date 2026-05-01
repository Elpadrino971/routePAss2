import SwiftUI

/// Conteneur principal post-auth — TabView swipe horizontal entre les 7 sections
/// avec un dock or signature en bas.
///
/// Sections (ordre fixe) :
///   0. Accueil
///   1. Transport
///   2. Location
///   3. Outils
///   4. Immobilier
///   5. Carte (géolocalisation prestataires + biens)
///   6. Compte
struct ContentView: View {
    @State private var currentPage: Int = 0
    @State private var hapticTrigger: Int = 0

    private let pages: [TabSpec] = [
        .init(id: 0, label: "Accueil",     icon: "house.fill"),
        .init(id: 1, label: "Transport",   icon: "car.fill"),
        .init(id: 2, label: "Location",    icon: "key.fill"),
        .init(id: 3, label: "Outils",      icon: "wrench.and.screwdriver.fill"),
        .init(id: 4, label: "Immobilier",  icon: "building.2.fill"),
        .init(id: 5, label: "Carte",       icon: "map.fill"),
        .init(id: 6, label: "Compte",      icon: "person.fill"),
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
                // Demande la position dès l'entrée — la carte et les listes
                // pourront filtrer par proximité.
                LocationManager.shared.requestAuthorization()
            }

            bottomDock
        }
        .background(RPTheme.black)
        .preferredColorScheme(.dark)
    }

    // MARK: - Dock

    private var bottomDock: some View {
        HStack(spacing: 0) {
            ForEach(pages) { page in
                tabButton(page: page)
            }
        }
        .padding(.horizontal, 6)
        .padding(.top, 8)
        .padding(.bottom, 6)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(RPTheme.dark.opacity(0.92))
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(RPTheme.border, lineWidth: 1)
                )
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .rpCardShadow()
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 6)
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
                        .frame(width: 16, height: 2)
                        .transition(.scale.combined(with: .opacity))
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
