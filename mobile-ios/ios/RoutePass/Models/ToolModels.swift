import Foundation
import SwiftUI
import CoreLocation

nonisolated enum ToolCategory: String, CaseIterable, Identifiable, Sendable {
    case outilsManuels = "Outils manuels"
    case machines = "Machines"
    case enginsBTP = "Engins BTP"
    case agricole = "Matériel agricole"
    case evenementiel = "Événementiel"
    case nautique = "Équip. nautique"

    nonisolated var id: String { rawValue }

    var emoji: String {
        switch self {
        case .outilsManuels: "🔧"
        case .machines: "⚙️"
        case .enginsBTP: "🏗️"
        case .agricole: "🌿"
        case .evenementiel: "🎪"
        case .nautique: "🚤"
        }
    }

    var icon: String {
        switch self {
        case .outilsManuels: "wrench.fill"
        case .machines: "gearshape.2.fill"
        case .enginsBTP: "square.stack.3d.up.fill"
        case .agricole: "leaf.fill"
        case .evenementiel: "speaker.wave.3.fill"
        case .nautique: "water.waves"
        }
    }

    var itemCount: Int {
        switch self {
        case .outilsManuels: 32
        case .machines: 18
        case .enginsBTP: 9
        case .agricole: 14
        case .evenementiel: 22
        case .nautique: 11
        }
    }
}

nonisolated enum ToolCondition: String, Sendable {
    case neuf = "Neuf"
    case bonEtat = "Bon état"
    case usureNormale = "Usure normale"

    var color: Color {
        switch self {
        case .neuf: .green
        case .bonEtat: .blue
        case .usureNormale: .orange
        }
    }

    var icon: String {
        switch self {
        case .neuf: "sparkles"
        case .bonEtat: "hand.thumbsup.fill"
        case .usureNormale: "wrench.fill"
        }
    }
}

nonisolated enum SkillLevel: String, Sendable {
    case debutant = "Débutant"
    case intermediaire = "Intermédiaire"
    case professionnel = "Professionnel"

    var color: Color {
        switch self {
        case .debutant: .green
        case .intermediaire: .orange
        case .professionnel: .red
        }
    }

    var icon: String {
        switch self {
        case .debutant: "person.fill"
        case .intermediaire: "person.2.fill"
        case .professionnel: "person.3.fill"
        }
    }
}

nonisolated enum AccessMethod: String, Sendable {
    case codeBoitier = "Code boîtier"
    case qrAccess = "QR Code"
    case mainPropre = "Remise en main propre"
    case livraison = "Livraison disponible"
}

nonisolated struct ToolItem: Identifiable, Sendable {
    let id: String
    let name: String
    let description: String
    let category: ToolCategory
    let status: RPStatus
    let ownerName: String
    let ownerVerified: Bool
    let rating: Double
    let reviewCount: Int
    let brand: String
    let model: String
    let year: Int
    let condition: ToolCondition
    let skillLevel: SkillLevel
    let weight: String
    let dimensions: String
    let consumablesIncluded: Bool
    let consumablesDetail: String?
    let hasManual: Bool
    let pricePerHour: String?
    let pricePerDay: String
    let pricePerWeek: String
    let pricePerMonth: String
    let deposit: String
    let icon: String
    let gallery: [String]
    let features: [String]
    let occupiedUntil: Date?
    let cleaningMinutes: Int
    let nextAvailable: String?
    let latitude: Double
    let longitude: Double
    let address: String
    let accessMethod: AccessMethod
    let deliveryAvailable: Bool
    let deliveryPrice: String?
    let insuranceRate: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var weekDiscount: String { "-10%" }
    var monthDiscount: String { "-20%" }

    var discountedWeekPrice: String {
        let digits = pricePerWeek.filter { $0.isNumber }
        guard let val = Int(digits) else { return pricePerWeek }
        let discounted = Int(Double(val) * 0.9)
        return formatEuro(discounted)
    }

    var discountedMonthPrice: String {
        let digits = pricePerMonth.filter { $0.isNumber }
        guard let val = Int(digits) else { return pricePerMonth }
        let discounted = Int(Double(val) * 0.8)
        return formatEuro(discounted)
    }

    private func formatEuro(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        let formatted = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(formatted) €"
    }
}

nonisolated struct ToolBooking: Identifiable, Sendable {
    let id: String
    let tool: ToolItem
    let startDate: Date
    let endDate: Date
    let totalAmount: String
    let depositAmount: String
    let accessCode: String
    let status: BookingStatus
    let hasInsurance: Bool
    let insuranceAmount: String?
}

nonisolated struct RestitutionChecklist: Sendable {
    var isClean: Bool = false
    var isFunctional: Bool = false
    var isComplete: Bool = false
    var noDamage: Bool = true
    var damageAmount: Double = 0
    var beforePhotos: [String] = []
    var afterPhotos: [String] = []

    var allChecked: Bool {
        isClean && isFunctional && isComplete && noDamage
    }
}

nonisolated struct OwnerTool: Identifiable, Sendable {
    let id: String
    let tool: ToolItem
    let todayRevenue: String
    let weekRevenue: String
    let monthRevenue: String
    let totalRevenue: String
    let reservationCount: Int
    let bookings: [ToolBooking]
}

nonisolated struct ToolRevenueData: Identifiable, Sendable {
    let id: String
    let toolName: String
    let icon: String
    let revenue: String
    let percentage: Double
}
