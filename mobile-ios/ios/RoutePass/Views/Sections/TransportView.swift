import SwiftUI

struct TransportView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = TransportViewModel()
    @State private var hapticTrigger: Int = 0

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

    private var clientView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                RPSectionHeader(
                    title: "Transport",
                    subtitle: "Trouvez votre prestataire",
                    icon: "car.fill"
                )

                categoriesSection

                scanButton

                filterChips

                providersSection
            }
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.refresh()
        }
        .sensoryFeedback(.selection, trigger: hapticTrigger)
        .task {
            await viewModel.loadData()
        }
    }

    private var categoriesSection: some View {
        ScrollView(.horizontal) {
            HStack(spacing: RPTheme.Spacing.md) {
                ForEach(viewModel.categories) { category in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            if viewModel.selectedCategory?.id == category.id {
                                viewModel.selectedCategory = nil
                            } else {
                                viewModel.selectedCategory = category
                            }
                        }
                        hapticTrigger += 1
                    } label: {
                        TransportCategoryCard(
                            category: category,
                            isSelected: viewModel.selectedCategory?.id == category.id
                        )
                    }
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .scrollIndicators(.hidden)
        .padding(.vertical, RPTheme.Spacing.md)
    }

    private var scanButton: some View {
        Button {
            viewModel.startScan()
        } label: {
            HStack(spacing: RPTheme.Spacing.sm) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 20))
                    .symbolEffect(.pulse)
                Text("Scanner un QR code")
                    .font(.system(.body, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [RPTheme.accent, RPTheme.accentDark],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(.rect(cornerRadius: RPTheme.buttonRadius))
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .padding(.bottom, RPTheme.Spacing.md)
    }

    private var filterChips: some View {
        ScrollView(.horizontal) {
            HStack(spacing: RPTheme.Spacing.sm) {
                ForEach(["Tous", "Disponible", "Meilleure note", "Plus proche"], id: \.self) { filter in
                    Button(filter) {}
                        .font(.system(.subheadline, design: .default, weight: .medium))
                        .foregroundStyle(filter == "Tous" ? .white : RPTheme.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(filter == "Tous" ? RPTheme.accent : Color(.tertiarySystemFill))
                        .clipShape(Capsule())
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .scrollIndicators(.hidden)
        .padding(.bottom, RPTheme.Spacing.md)
    }

    private var providersSection: some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            if viewModel.isLoading {
                ForEach(0..<4, id: \.self) { _ in
                    ShimmerCardView()
                }
            } else {
                HStack {
                    Text("\(viewModel.filteredProviders.count) prestataires")
                        .font(.system(.subheadline, design: .default, weight: .semibold))
                        .foregroundStyle(RPTheme.textSecondary)
                    Spacer()
                }

                if viewModel.filteredProviders.isEmpty {
                    RPEmptyState(
                        icon: "car.fill",
                        title: "Aucun prestataire",
                        message: "Aucun prestataire disponible dans cette catégorie pour le moment."
                    )
                } else {
                    ForEach(viewModel.filteredProviders) { provider in
                        Button {
                            viewModel.selectProvider(provider)
                        } label: {
                            ProviderCard(provider: provider)
                        }
                        .contextMenu {
                            Button {
                            } label: {
                                Label("Voir le profil", systemImage: "person.crop.circle")
                            }
                            Button {
                            } label: {
                                Label("Appeler", systemImage: "phone.fill")
                            }
                            Button {
                            } label: {
                                Label("Ajouter aux favoris", systemImage: "heart")
                            }
                        }
                        .sensoryFeedback(.impact(flexibility: .soft), trigger: viewModel.showPaymentRecap)
                    }
                }
            }
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .padding(.bottom, 80)
    }
}
