import SwiftUI

@Observable
final class LocationViewModel {
    var items: [RentalItem] = LocationMockData.rentalItems
    var selectedCategory: RentalCategory?
    var selectedFilter: String = "Tous"
    var isLoading: Bool = true

    var showDetail: Bool = false
    var selectedItem: RentalItem?

    var showBookingFlow: Bool = false
    var bookingStartDate: Date = Date()
    var bookingEndDate: Date = Date().addingTimeInterval(86400)
    var selectedPricingUnit: PricingUnit = .day
    var isProcessingPayment: Bool = false

    var showBookingConfirmation: Bool = false
    var currentBooking: RentalBooking?

    var showAccessView: Bool = false
    var showMapTracking: Bool = false

    var weekEvents: [WeekEvent] = LocationMockData.weekEvents
    var tenantHistory: [TenantRecord] = LocationMockData.tenantHistory

    var ownerTodayRevenue: String = "850 €"
    var ownerWeekRevenue: String = "4 200 €"
    var ownerMonthRevenue: String = "16 500 €"
    var ownerPropertyStatus: RPStatus = .nettoyage
    var ownerCleaningMinutes: Int = 45

    let filters: [String] = ["Tous", "Disponible", "Prix ↑", "Mieux noté"]

    var filteredItems: [RentalItem] {
        var result = items
        if let cat = selectedCategory {
            result = result.filter { $0.category == cat }
        }
        switch selectedFilter {
        case "Disponible":
            result = result.filter { $0.status == .disponible }
        case "Prix ↑":
            result = result.sorted { extractPrice($0.pricePerDay) < extractPrice($1.pricePerDay) }
        case "Mieux noté":
            result = result.sorted { $0.rating > $1.rating }
        default:
            break
        }
        return result
    }

    func selectItem(_ item: RentalItem) {
        selectedItem = item
        showDetail = true
    }

    func startBooking() {
        showBookingFlow = true
    }

    func processBooking() {
        guard let item = selectedItem else { return }
        isProcessingPayment = true

        let code = (0..<6).map { _ in String(Int.random(in: 0...9)) }.joined()

        Task {
            try? await Task.sleep(for: .seconds(1.5))
            let booking = RentalBooking(
                id: UUID().uuidString,
                item: item,
                startDate: bookingStartDate,
                endDate: bookingEndDate,
                totalAmount: computedTotal,
                depositAmount: item.deposit,
                accessCode: code,
                status: .active
            )
            currentBooking = booking
            isProcessingPayment = false
            showBookingFlow = false
            showDetail = false
            showBookingConfirmation = true
        }
    }

    func openAccess() {
        showBookingConfirmation = false
        showAccessView = true
    }

    func endRental() {
        showAccessView = false
        currentBooking = nil
        selectedItem = nil
    }

    func openMapAfterBooking() {
        showBookingConfirmation = false
        showMapTracking = true
    }

    func dismissDetail() {
        showDetail = false
        selectedItem = nil
        selectedPricingUnit = .day
    }

    var computedTotal: String {
        guard let item = selectedItem else { return "0 €" }
        switch selectedPricingUnit {
        case .hour: return item.pricePerHour ?? item.pricePerDay
        case .day: return item.pricePerDay
        case .week: return item.pricePerWeek
        case .month: return item.pricePerMonth
        }
    }

    var bookingDurationText: String {
        let days = Calendar.current.dateComponents([.day], from: bookingStartDate, to: bookingEndDate).day ?? 1
        let d = max(days, 1)
        return d == 1 ? "1 jour" : "\(d) jours"
    }

    func loadData() async {
        try? await Task.sleep(for: .seconds(0.8))
        isLoading = false
    }

    func refresh() async {
        isLoading = true
        items = LocationMockData.rentalItems.shuffled()
        try? await Task.sleep(for: .seconds(0.6))
        isLoading = false
    }

    private func extractPrice(_ price: String) -> Int {
        let digits = price.filter { $0.isNumber }
        return Int(digits) ?? 0
    }
}

nonisolated enum PricingUnit: String, CaseIterable, Identifiable, Sendable {
    case hour = "Heure"
    case day = "Jour"
    case week = "Semaine"
    case month = "Mois"

    nonisolated var id: String { rawValue }
}
