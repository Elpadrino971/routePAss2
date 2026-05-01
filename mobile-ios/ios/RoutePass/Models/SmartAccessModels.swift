import Foundation
import SwiftUI

nonisolated enum AccessCardState: String, Sendable {
    case inactive = "Inactive"
    case activating = "Activation..."
    case active = "Active"
    case expired = "Expirée"
    case revoked = "Révoquée"

    var color: Color {
        switch self {
        case .inactive: .gray
        case .activating: .orange
        case .active: .green
        case .expired: .red
        case .revoked: .red
        }
    }

    var icon: String {
        switch self {
        case .inactive: "creditcard"
        case .activating: "arrow.triangle.2.circlepath"
        case .active: "checkmark.shield.fill"
        case .expired: "clock.badge.xmark"
        case .revoked: "xmark.shield.fill"
        }
    }
}

nonisolated enum SmartDeviceType: String, Sendable, Identifiable {
    case door = "Serrure"
    case electricity = "Électricité"
    case motor = "Moteur"
    case gate = "Portail"

    nonisolated var id: String { rawValue }

    var icon: String {
        switch self {
        case .door: "door.left.hand.closed"
        case .electricity: "bolt.fill"
        case .motor: "engine.combustion.fill"
        case .gate: "door.garage.closed"
        }
    }

    var activeIcon: String {
        switch self {
        case .door: "door.left.hand.open"
        case .electricity: "bolt.fill"
        case .motor: "engine.combustion.fill"
        case .gate: "door.garage.open"
        }
    }
}

nonisolated struct SmartDevice: Identifiable, Sendable {
    let id: String
    let type: SmartDeviceType
    let name: String
    var isActive: Bool
    let isControllable: Bool
}

nonisolated struct AccessLogEntry: Identifiable, Sendable {
    let id: String
    let event: String
    let icon: String
    let color: Color
    let timestamp: Date
}

nonisolated struct SmartAccessCard: Identifiable, Sendable {
    let id: String
    let cardNumber: String
    let bookingId: String
    let propertyName: String
    let propertyIcon: String
    var state: AccessCardState
    let activationDate: Date
    let expirationDate: Date
    let devices: [SmartDevice]
    let accessLog: [AccessLogEntry]
}

enum SmartAccessMockData {
    static func createCard(for booking: RentalBooking) -> SmartAccessCard {
        let cardNum = (0..<4).map { _ in
            String(format: "%04d", Int.random(in: 0...9999))
        }.joined(separator: " ")

        return SmartAccessCard(
            id: UUID().uuidString,
            cardNumber: cardNum,
            bookingId: booking.id,
            propertyName: booking.item.name,
            propertyIcon: booking.item.icon,
            state: .active,
            activationDate: booking.startDate,
            expirationDate: booking.endDate,
            devices: devicesForCategory(booking.item.category),
            accessLog: generateLog(for: booking)
        )
    }

    static func devicesForCategory(_ category: RentalCategory) -> [SmartDevice] {
        switch category {
        case .appartements, .saisonnieres:
            return [
                SmartDevice(id: "d1", type: .door, name: "Porte principale", isActive: true, isControllable: true),
                SmartDevice(id: "d2", type: .electricity, name: "Compteur principal", isActive: true, isControllable: true),
                SmartDevice(id: "d3", type: .gate, name: "Portail parking", isActive: true, isControllable: true),
            ]
        case .vehicules:
            return [
                SmartDevice(id: "d1", type: .door, name: "Déverrouillage", isActive: true, isControllable: true),
                SmartDevice(id: "d2", type: .motor, name: "Démarrage moteur", isActive: true, isControllable: true),
            ]
        case .bateaux:
            return [
                SmartDevice(id: "d1", type: .door, name: "Accès cabine", isActive: true, isControllable: true),
                SmartDevice(id: "d2", type: .motor, name: "Moteur", isActive: true, isControllable: true),
                SmartDevice(id: "d3", type: .electricity, name: "Électricité bord", isActive: true, isControllable: true),
            ]
        }
    }

    static func generateLog(for booking: RentalBooking) -> [AccessLogEntry] {
        let now = Date()
        return [
            AccessLogEntry(id: "l1", event: "Carte NFC activée", icon: "creditcard.fill", color: .green, timestamp: now.addingTimeInterval(-120)),
            AccessLogEntry(id: "l2", event: "Serrure déverrouillée", icon: "lock.open.fill", color: .green, timestamp: now.addingTimeInterval(-90)),
            AccessLogEntry(id: "l3", event: "Électricité activée", icon: "bolt.fill", color: .yellow, timestamp: now.addingTimeInterval(-88)),
            AccessLogEntry(id: "l4", event: "Portail ouvert", icon: "door.garage.open", color: .blue, timestamp: now.addingTimeInterval(-60)),
        ]
    }

    static func ownerAccessLog() -> [AccessLogEntry] {
        let now = Date()
        return [
            AccessLogEntry(id: "ol1", event: "Carte #4821 activée — Lucas M.", icon: "creditcard.fill", color: .green, timestamp: now.addingTimeInterval(-7200)),
            AccessLogEntry(id: "ol2", event: "Porte déverrouillée", icon: "lock.open.fill", color: .green, timestamp: now.addingTimeInterval(-7190)),
            AccessLogEntry(id: "ol3", event: "Électricité ON", icon: "bolt.fill", color: .yellow, timestamp: now.addingTimeInterval(-7185)),
            AccessLogEntry(id: "ol4", event: "Carte #3902 expirée — Marie D.", icon: "clock.badge.xmark", color: .red, timestamp: now.addingTimeInterval(-28800)),
            AccessLogEntry(id: "ol5", event: "Électricité OFF (auto)", icon: "bolt.slash.fill", color: .orange, timestamp: now.addingTimeInterval(-28800)),
            AccessLogEntry(id: "ol6", event: "Serrure verrouillée (auto)", icon: "lock.fill", color: .red, timestamp: now.addingTimeInterval(-28800)),
            AccessLogEntry(id: "ol7", event: "Nettoyage déclenché", icon: "sparkles", color: .orange, timestamp: now.addingTimeInterval(-28790)),
            AccessLogEntry(id: "ol8", event: "Bien marqué disponible", icon: "checkmark.circle.fill", color: .green, timestamp: now.addingTimeInterval(-25200)),
        ]
    }
}
