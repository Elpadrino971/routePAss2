import SwiftUI

/// Transport ROUTEPASS — reprend exactement le mockup iPhone 16 :
///   "🚗 Transport · Trouvez votre prestataire"
///   Grille 2x2 catégories (Taxi 24 dispo / Minibus 12 / Bateau 6 / Fret 18)
///   Bouton or "Scanner un QR code"
///   Chips filtres (Tous / Disponible / Meilleure note / Plus proche)
///   Liste prestataires avec avatar+verified, étoiles, prix, "Disponible".
struct TransportView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = TransportViewModel()
    @State private var hapticTrigger: Int = 0
    @State private var activeFilter: TransportFilter = .all
    @State private var providers: [RPProvider] = RPProvider.mock

    private var isPrestataire: Bool {
        appState.selectedRole == .prestataire
    }

    var body: some View {
        Group {
            if isPrestataire {
                PrestataireView()
            } else {
                clientView
            }
        }
        .fullScreenCover(isPresented: $viewModel.showScanner) {
            QRScannerView(
                onDetected: { viewModel.onQRDetected() },
                onDismiss: { viewModel.showScanner = false }
            )
        }
        .sheet(isPresented: $viewModel.showPaymentRecap) {
            if let provider = viewModel.selectedProvider {
                PaymentRecapSheet(
                    provider: provider,
                    isProcessing: viewModel.isProcessingPayment,
                    onPayApplePay: { viewModel.processPayment() },
                    onDismiss: { viewModel.showPaymentRecap = false }
                )
            }
        }
        .fullScreenCover(isPresented: $viewModel.showConfirmation) {
            if let provider = viewModel.selectedProvider {
                PaymentConfirmationView(
                    code: viewModel.paymentCode,
                    providerName: provider.name,
                    provider: provider,
                    onDismiss: { viewModel.dismissConfirmation() },
                    onShowMap: { viewModel.openMapAfterPayment() }
                )
            }
        }
        .fullScreenCover(isPresented: $viewModel.showMapTracking) {
            MapTrackingView(
                mapItems: [],
                isPaymentConfirmed: true,
                activeProvider: viewModel.selectedProvider,
                activeBooking: nil,
                onDismiss: {
                    viewModel.showMapTracking = false
                    viewModel.selectedProvider = nil
                    viewModel.paymentCode = ""
                }
            )
        }
    }

    // MARK: - Client view

    private var clientView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                categoriesGrid
                scanButton
                filtersRow
                providersList
            }
            .padding(.top, 12)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background(RPTheme.black.ignoresSafeArea())
        .task {
            await viewModel.loadData()
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(RPTheme.dark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(RPTheme.gold.opacity(0.4), lineWidth: 1)
                    )
                Image(systemName: "car.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(RPTheme.gold)
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 1) {
                Text("Transport")
                    .font(RPFont.display(22))
                    .foregroundStyle(RPTheme.white)
                Text("Trouvez votre prestataire")
                    .font(RPFont.body(12))
                    .foregroundStyle(RPTheme.gray)
            }
            Spacer()
        }
        .padding(.horizontal, RPTheme.Spacing.lg)
    }

    private var categoriesGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
        return LazyVGrid(columns: columns, spacing: 10) {
            RPCategoryTile(icon: "car.fill",         label: "Taxi",    availableCount: 24, imageURL: "https://images.unsplash.com/photo-1542362567-b07e54358753?auto=format&fit=crop&w=600&q=80")
            RPCategoryTile(icon: "bus.fill",         label: "Minibus", availableCount: 12, imageURL: "https://images.unsplash.com/photo-1597007029837-2db5e2dd5d54?auto=format&fit=crop&w=600&q=80")
            RPCategoryTile(icon: "ferry.fill",       label: "Bateau",  availableCount: 6,  imageURL: "https://images.unsplash.com/photo-1542558817-5d8d717a85e9?auto=format&fit=crop&w=600&q=80")
            RPCategoryTile(icon: "shippingbox.fill", label: "Fret",    availableCount: 18, imageURL: "https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?auto=format&fit=crop&w=600&q=80")
        }
        .padding(.horizontal, RPTheme.Spacing.lg)
    }

    private var scanButton: some View {
        Button {
            viewModel.startScan()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 18, weight: .semibold))
                    .symbolEffect(.pulse)
                Text("Scanner un QR code")
            }
            .font(RPFont.body(15, weight: .semibold))
            .foregroundStyle(RPTheme.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(RPTheme.goldGradient)
            .clipShape(.rect(cornerRadius: RPTheme.buttonRadius))
            .shadow(color: RPTheme.gold.opacity(0.3), radius: 14, y: 4)
        }
        .padding(.horizontal, RPTheme.Spacing.lg)
    }

    private var filtersRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TransportFilter.allCases) { filter in
                    RPFilterChip(label: filter.label, isActive: filter == activeFilter) {
                        withAnimation { activeFilter = filter }
                        hapticTrigger += 1
                    }
                }
            }
            .padding(.horizontal, RPTheme.Spacing.lg)
        }
        .sensoryFeedback(.selection, trigger: hapticTrigger)
    }

    private var providersList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(filteredProviders.count) prestataires")
                .font(RPFont.body(13, weight: .semibold))
                .foregroundStyle(RPTheme.gray)
                .padding(.horizontal, RPTheme.Spacing.lg)

            VStack(spacing: 8) {
                ForEach(filteredProviders) { p in
                    RPProviderRow(provider: p) {
                        viewModel.startScan()
                    }
                }
            }
            .padding(.horizontal, RPTheme.Spacing.lg)
        }
    }

    private var filteredProviders: [RPProvider] {
        switch activeFilter {
        case .all:        return providers
        case .available:  return providers
        case .topRated:   return providers.sorted { $0.rating > $1.rating }
        case .closest:    return providers.sorted { ($0.distanceKm ?? .infinity) < ($1.distanceKm ?? .infinity) }
        }
    }
}

// MARK: - Filtres

private enum TransportFilter: String, CaseIterable, Identifiable {
    case all, available, topRated, closest

    var id: String { rawValue }
    var label: String {
        switch self {
        case .all:        "Tous"
        case .available:  "Disponible"
        case .topRated:   "Meilleure note"
        case .closest:    "Plus proche"
        }
    }
}
