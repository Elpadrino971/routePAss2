import SwiftUI

@Observable
final class TransportViewModel {
    var categories: [TransportCategory] = TransportMockData.categories
    var providers: [Provider] = TransportMockData.providers
    var selectedCategory: TransportCategory?
    var selectedProvider: Provider?
    var isLoading: Bool = true

    var showScanner: Bool = false
    var showPaymentRecap: Bool = false
    var showConfirmation: Bool = false
    var showPrestataireView: Bool = false

    var paymentCode: String = ""
    var validationCode: String = ""
    var isProcessingPayment: Bool = false
    var codeValidated: Bool = false

    var showMapTracking: Bool = false

    var dailySummary: DailySummary = TransportMockData.dailySummary

    var filteredProviders: [Provider] {
        guard let cat = selectedCategory else { return providers }
        return providers.filter { $0.categoryID == cat.id }
    }

    func selectProvider(_ provider: Provider) {
        selectedProvider = provider
        showPaymentRecap = true
    }

    func startScan() {
        showScanner = true
    }

    func onQRDetected() {
        showScanner = false
        if let first = providers.first(where: { $0.status == .disponible }) {
            selectedProvider = first
        }
        showPaymentRecap = true
    }

    func processPayment() {
        isProcessingPayment = true
        let digits = (0..<4).map { _ in String(Int.random(in: 0...9)) }.joined()
        paymentCode = digits

        Task {
            try? await Task.sleep(for: .seconds(1.5))
            isProcessingPayment = false
            showPaymentRecap = false
            showConfirmation = true
        }
    }

    func dismissConfirmation() {
        showConfirmation = false
        selectedProvider = nil
        paymentCode = ""
    }

    func openMapAfterPayment() {
        showConfirmation = false
        showMapTracking = true
    }

    func validateCode(_ code: String) -> Bool {
        let valid = dailySummary.trips.contains { $0.code == code }
        codeValidated = valid
        return valid
    }

    func resetValidation() {
        validationCode = ""
        codeValidated = false
    }

    func loadData() async {
        try? await Task.sleep(for: .seconds(0.8))
        isLoading = false
    }

    func refresh() async {
        isLoading = true
        providers = TransportMockData.providers.shuffled()
        try? await Task.sleep(for: .seconds(0.6))
        isLoading = false
    }
}
