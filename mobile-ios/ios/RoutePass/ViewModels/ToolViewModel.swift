import SwiftUI

@Observable
final class ToolViewModel {
    var tools: [ToolItem] = ToolMockData.tools
    var selectedCategory: ToolCategory?
    var selectedFilter: String = "Tous"
    var isLoading: Bool = true

    var showDetail: Bool = false
    var selectedTool: ToolItem?

    var showBookingFlow: Bool = false
    var bookingStartDate: Date = Date()
    var bookingEndDate: Date = Date().addingTimeInterval(86400)
    var selectedPricingUnit: PricingUnit = .day
    var isProcessingPayment: Bool = false
    var addInsurance: Bool = false

    var showBookingConfirmation: Bool = false
    var currentBooking: ToolBooking?

    var showAccessView: Bool = false
    var showMapTracking: Bool = false
    var showRestitution: Bool = false

    var restitutionChecklist = RestitutionChecklist()

    var ownerTools: [OwnerTool] = ToolMockData.ownerTools
    var ownerWeekEvents: [WeekEvent] = ToolMockData.weekEvents
    var showAddTool: Bool = false

    let filters: [String] = ["Tous", "Disponible", "Prix ↑", "Mieux noté", "Livrable"]

    var filteredTools: [ToolItem] {
        var result = tools
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
        case "Livrable":
            result = result.filter { $0.deliveryAvailable }
        default:
            break
        }
        return result
    }

    func selectTool(_ tool: ToolItem) {
        selectedTool = tool
        showDetail = true
    }

    func startBooking() {
        showBookingFlow = true
    }

    func processBooking() {
        guard let tool = selectedTool else { return }
        isProcessingPayment = true

        let code = (0..<6).map { _ in String(Int.random(in: 0...9)) }.joined()
        let insuranceAmt: String? = addInsurance ? computeInsurance(tool) : nil

        Task {
            try? await Task.sleep(for: .seconds(1.5))
            let booking = ToolBooking(
                id: UUID().uuidString,
                tool: tool,
                startDate: bookingStartDate,
                endDate: bookingEndDate,
                totalAmount: computedTotal,
                depositAmount: tool.deposit,
                accessCode: code,
                status: .active,
                hasInsurance: addInsurance,
                insuranceAmount: insuranceAmt
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

    func openMapAfterBooking() {
        showBookingConfirmation = false
        showMapTracking = true
    }

    func endRental() {
        showAccessView = false
        showRestitution = true
    }

    func confirmRestitution() {
        showRestitution = false
        currentBooking = nil
        selectedTool = nil
        restitutionChecklist = RestitutionChecklist()
    }

    func dismissDetail() {
        showDetail = false
        selectedTool = nil
        selectedPricingUnit = .day
        addInsurance = false
    }

    var computedTotal: String {
        guard let tool = selectedTool else { return "0 €" }
        switch selectedPricingUnit {
        case .hour: return tool.pricePerHour ?? tool.pricePerDay
        case .day: return tool.pricePerDay
        case .week: return tool.discountedWeekPrice
        case .month: return tool.discountedMonthPrice
        }
    }

    var bookingDurationText: String {
        let days = Calendar.current.dateComponents([.day], from: bookingStartDate, to: bookingEndDate).day ?? 1
        let d = max(days, 1)
        return d == 1 ? "1 jour" : "\(d) jours"
    }

    func computeInsurance(_ tool: ToolItem) -> String {
        let digits = computedTotal.filter { $0.isNumber }
        guard let val = Int(digits) else { return "0 €" }
        let insurance = Int(Double(val) * tool.insuranceRate)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        let formatted = formatter.string(from: NSNumber(value: insurance)) ?? "\(insurance)"
        return "\(formatted) €"
    }

    func loadData() async {
        try? await Task.sleep(for: .seconds(0.8))
        isLoading = false
    }

    func refresh() async {
        isLoading = true
        tools = ToolMockData.tools.shuffled()
        try? await Task.sleep(for: .seconds(0.6))
        isLoading = false
    }

    private func extractPrice(_ price: String) -> Int {
        let digits = price.filter { $0.isNumber }
        return Int(digits) ?? 0
    }
}
