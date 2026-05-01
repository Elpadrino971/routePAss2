import Foundation
import SwiftUI
import CoreLocation

nonisolated enum RentalCategory: String, CaseIterable, Identifiable, Sendable {
    case vehicules = "Véhicules"
    case bateaux = "Bateaux"
    case appartements = "Appartements"
    case saisonnieres = "Saisonnières"

    nonisolated var id: String { rawValue }

    var emoji: String {
        switch self {
        case .vehicules: "🚗"
        case .bateaux: "🛥️"
        case .appartements: "🏠"
        case .saisonnieres: "🏖️"
        }
    }

    var icon: String {
        switch self {
        case .vehicules: "car.fill"
        case .bateaux: "ferry.fill"
        case .appartements: "building.2.fill"
        case .saisonnieres: "sun.horizon.fill"
        }
    }

    var itemCount: Int {
        switch self {
        case .vehicules: 18
        case .bateaux: 7
        case .appartements: 14
        case .saisonnieres: 9
        }
    }
}

nonisolated struct RentalItem: Identifiable, Sendable {
    let id: String
    let name: String
    let description: String
    let category: RentalCategory
    let status: RPStatus
    let ownerName: String
    let ownerVerified: Bool
    let rating: Double
    let reviewCount: Int
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

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

nonisolated struct RentalBooking: Identifiable, Sendable {
    let id: String
    let item: RentalItem
    let startDate: Date
    let endDate: Date
    let totalAmount: String
    let depositAmount: String
    let accessCode: String
    let status: BookingStatus
}

nonisolated enum BookingStatus: String, Sendable {
    case active = "En cours"
    case upcoming = "À venir"
    case completed = "Terminée"
}

nonisolated struct OwnerProperty: Identifiable, Sendable {
    let id: String
    let item: RentalItem
    let todayRevenue: String
    let weekRevenue: String
    let monthRevenue: String
    let tenantHistory: [TenantRecord]
    let blockedDates: [Date]
}

nonisolated struct TenantRecord: Identifiable, Sendable {
    let id: String
    let tenantName: String
    let dates: String
    let amount: String
    let rating: Double
}

nonisolated struct WeekEvent: Identifiable, Sendable {
    let id: String
    let title: String
    let day: String
    let timeRange: String
    let color: Color
}
