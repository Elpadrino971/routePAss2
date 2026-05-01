import SwiftUI

nonisolated enum RPStatus: String, CaseIterable, Sendable, Identifiable {
    case disponible = "Disponible"
    case occupe = "Occupé"
    case nettoyage = "Nettoyage"
    case libreLe = "Libre le 15 Avr"

    nonisolated var id: String { rawValue }

    var color: Color {
        switch self {
        case .disponible: .green
        case .occupe: .red
        case .nettoyage: .orange
        case .libreLe: .blue
        }
    }

    var icon: String {
        switch self {
        case .disponible: "checkmark.circle.fill"
        case .occupe: "xmark.circle.fill"
        case .nettoyage: "sparkles"
        case .libreLe: "calendar.circle.fill"
        }
    }
}
