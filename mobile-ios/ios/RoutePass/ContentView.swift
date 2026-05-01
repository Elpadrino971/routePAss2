import SwiftUI

struct ContentView: View {
    @State private var currentPage: Int = 0
    @State private var hapticTrigger: Int = 0

    private let pageCount = 6
    private let pageIcons = ["house.fill", "car.fill", "key.fill", "wrench.and.screwdriver.fill", "building.2.fill", "person.fill"]
    private let pageLabels = ["Accueil", "Transport", "Location", "Outils", "Immobilier", "Compte"]

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentPage) {
                AccueilView()
                    .tag(0)
                TransportView()
                    .tag(1)
                LocationView()
                    .tag(2)
                OutilsView()
                    .tag(3)
                ImmobilierView()
                    .tag(4)
                CompteView()
                    .tag(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)
            .onChange(of: currentPage) { _, _ in
                hapticTrigger += 1
            }
            .sensoryFeedback(.selection, trigger: hapticTrigger)

            bottomIndicator
        }
        .background(RPTheme.backgroundPrimary)
    }

    private var bottomIndicator: some View {
        HStack(spacing: 20) {
            ForEach(0..<pageCount, id: \.self) { index in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        currentPage = index
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: pageIcons[index])
                            .font(.system(size: index == currentPage ? 18 : 16))
                            .foregroundStyle(index == currentPage ? RPTheme.accent : RPTheme.textSecondary.opacity(0.5))
                            .symbolEffect(.bounce, value: index == currentPage ? hapticTrigger : 0)

                        Capsule()
                            .fill(index == currentPage ? RPTheme.accent : .clear)
                            .frame(width: index == currentPage ? 20 : 0, height: 3)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: currentPage)
            }
        }
        .padding(.horizontal, RPTheme.Spacing.lg)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}
