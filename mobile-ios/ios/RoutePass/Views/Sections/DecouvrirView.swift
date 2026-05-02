import SwiftUI

/// Page unifiée "Découvrir" — regroupe Transport / Location / Outils /
/// Immobilier dans une seule vue avec un sélecteur de catégorie en haut.
///
/// Évite de surcharger la nav du bas avec 7 onglets et offre une meilleure
/// expérience de "marketplace" (comme Uber, Airbnb, etc.).
struct DecouvrirView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedKind: ServiceKind = .transport
    @State private var hapticTrigger: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            header
            categorySelector
            content
        }
        .background(RPTheme.black.ignoresSafeArea())
        .sensoryFeedback(.selection, trigger: hapticTrigger)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(RPTheme.dark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(RPTheme.gold.opacity(0.4), lineWidth: 1)
                    )
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(RPTheme.gold)
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 1) {
                Text("Découvrir")
                    .font(RPFont.display(22))
                    .foregroundStyle(RPTheme.white)
                Text("Services premium autour de vous")
                    .font(RPFont.body(12))
                    .foregroundStyle(RPTheme.gray)
            }
            Spacer()
        }
        .padding(.horizontal, RPTheme.Spacing.lg)
        .padding(.top, 12)
        .padding(.bottom, 14)
    }

    // MARK: - Category selector

    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ServiceKind.allCases) { kind in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            selectedKind = kind
                        }
                        hapticTrigger += 1
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: kind.icon)
                                .font(.system(size: 12, weight: .semibold))
                            Text(kind.label)
                                .font(RPFont.body(13, weight: .semibold))
                        }
                        .foregroundStyle(selectedKind == kind ? RPTheme.black : RPTheme.gray)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(
                            Capsule()
                                .fill(selectedKind == kind
                                      ? AnyShapeStyle(RPTheme.goldGradient)
                                      : AnyShapeStyle(RPTheme.dark))
                        )
                        .overlay(
                            Capsule()
                                .stroke(selectedKind == kind ? Color.clear : RPTheme.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, RPTheme.Spacing.lg)
        }
        .padding(.bottom, 12)
    }

    // MARK: - Content (transition entre les 4 sous-vues)

    @ViewBuilder
    private var content: some View {
        switch selectedKind {
        case .transport:
            TransportView()
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        case .location:
            LocationView()
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        case .outils:
            OutilsView()
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        case .immobilier:
            ImmobilierView()
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        }
    }
}

// MARK: - Service kinds

private enum ServiceKind: String, CaseIterable, Identifiable {
    case transport, location, outils, immobilier

    var id: String { rawValue }

    var label: String {
        switch self {
        case .transport:  "Transport"
        case .location:   "Location"
        case .outils:     "Outils"
        case .immobilier: "Immobilier"
        }
    }

    var icon: String {
        switch self {
        case .transport:  "car.fill"
        case .location:   "key.fill"
        case .outils:     "wrench.and.screwdriver.fill"
        case .immobilier: "building.2.fill"
        }
    }
}
