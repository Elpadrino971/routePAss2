import SwiftUI

struct LocationView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = LocationViewModel()
    @State private var hapticTrigger: Int = 0

    private var isProprietaire: Bool {
        appState.selectedRole == .proprietaire
    }

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        Group {
            if isProprietaire {
                ProprietaireLocationView()
            } else {
                clientView
            }
        }
        .sheet(isPresented: $viewModel.showDetail) {
            if let item = viewModel.selectedItem {
                RentalDetailView(
                    item: item,
                    selectedPricingUnit: $viewModel.selectedPricingUnit,
                    computedTotal: viewModel.computedTotal,
                    onBook: { viewModel.startBooking() },
                    onDismiss: { viewModel.dismissDetail() }
                )
            }
        }
        .sheet(isPresented: $viewModel.showBookingFlow) {
            if let item = viewModel.selectedItem {
                BookingFlowSheet(
                    item: item,
                    startDate: $viewModel.bookingStartDate,
                    endDate: $viewModel.bookingEndDate,
                    durationText: viewModel.bookingDurationText,
                    totalAmount: viewModel.computedTotal,
                    isProcessing: viewModel.isProcessingPayment,
                    onConfirm: { viewModel.processBooking() },
                    onDismiss: { viewModel.showBookingFlow = false }
                )
            }
        }
        .fullScreenCover(isPresented: $viewModel.showBookingConfirmation) {
            if let booking = viewModel.currentBooking {
                BookingConfirmationView(
                    booking: booking,
                    onAccessView: { viewModel.openAccess() },
                    onShowMap: { viewModel.openMapAfterBooking() },
                    onDismiss: {
                        viewModel.showBookingConfirmation = false
                        viewModel.currentBooking = nil
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $viewModel.showAccessView) {
            if let booking = viewModel.currentBooking {
                AutonomousAccessView(
                    booking: booking,
                    onEndRental: { viewModel.endRental() },
                    onDismiss: { viewModel.showAccessView = false }
                )
            }
        }
        .fullScreenCover(isPresented: $viewModel.showMapTracking) {
            MapTrackingView(
                mapItems: [],
                isPaymentConfirmed: true,
                activeProvider: nil,
                activeBooking: viewModel.currentBooking,
                onDismiss: {
                    viewModel.showMapTracking = false
                }
            )
        }
    }

    private var clientView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                categoriesSection
                filterChips
                catalogSection
            }
            .padding(.top, 4)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background(RPTheme.black.ignoresSafeArea())
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
                ForEach(RentalCategory.allCases) { category in
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
                        RentalCategoryCard(
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

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.filters, id: \.self) { filter in
                    RPFilterChip(label: filter, isActive: viewModel.selectedFilter == filter) {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.selectedFilter = filter
                        }
                        hapticTrigger += 1
                    }
                }
            }
            .padding(.horizontal, RPTheme.Spacing.lg)
        }
    }

    private var catalogSection: some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            if viewModel.isLoading {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(0..<4, id: \.self) { _ in
                        ShimmerLocationCard()
                    }
                }
                .padding(.horizontal, RPTheme.Spacing.md)
            } else {
                HStack {
                    Text("\(viewModel.filteredItems.count) biens disponibles")
                        .font(RPFont.body(13, weight: .semibold))
                        .foregroundStyle(RPTheme.gray)
                    Spacer()
                }
                .padding(.horizontal, RPTheme.Spacing.lg)

                if viewModel.filteredItems.isEmpty {
                    RPEmptyState(
                        icon: "key.fill",
                        title: "Aucun bien disponible",
                        message: "Aucun bien ne correspond à vos critères pour le moment."
                    )
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.filteredItems) { item in
                            Button {
                                viewModel.selectItem(item)
                            } label: {
                                RentalGridCard(item: item)
                            }
                            .buttonStyle(.plain)
                            .sensoryFeedback(.impact(flexibility: .soft), trigger: viewModel.showDetail)
                        }
                    }
                    .padding(.horizontal, RPTheme.Spacing.lg)
                }
            }
        }
        .padding(.bottom, 80)
    }
}

struct ShimmerLocationCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ShimmerView().frame(height: 130)
            ShimmerView().frame(height: 13).frame(maxWidth: 120)
            ShimmerView().frame(height: 10).frame(maxWidth: 80)
            ShimmerView().frame(height: 14).frame(maxWidth: 80)
        }
        .padding(10)
        .background(RPTheme.dark)
        .overlay(
            RoundedRectangle(cornerRadius: RPTheme.cardRadius)
                .stroke(RPTheme.border, lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
    }
}
