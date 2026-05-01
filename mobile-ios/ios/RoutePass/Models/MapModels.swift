import Foundation
import CoreLocation
import SwiftUI

nonisolated enum MapItemCategory: String, Sendable {
    case taxi
    case minibus
    case bateau
    case camion
    case vehicule
    case immobilier
    case outil

    var markerColor: Color {
        switch self {
        case .taxi: Color(red: 1, green: 0.8, blue: 0)
        case .minibus: .orange
        case .bateau: .blue
        case .camion: Color(red: 0.6, green: 0.6, blue: 0.65)
        case .vehicule: .green
        case .immobilier: Color(red: 212/255, green: 168/255, blue: 67/255)
        case .outil: .red
        }
    }

    var icon: String {
        switch self {
        case .taxi: "car.fill"
        case .minibus: "bus.fill"
        case .bateau: "ferry.fill"
        case .camion: "shippingbox.fill"
        case .vehicule: "car.fill"
        case .immobilier: "building.2.fill"
        case .outil: "wrench.and.screwdriver.fill"
        }
    }

    var label: String {
        switch self {
        case .taxi: "Taxi"
        case .minibus: "Minibus"
        case .bateau: "Bateau"
        case .camion: "Camion"
        case .vehicule: "Véhicule"
        case .immobilier: "Bien immobilier"
        case .outil: "Outil / Engin"
        }
    }
}

nonisolated struct MapItem: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let subtitle: String
    let category: MapItemCategory
    let status: RPStatus
    let coordinate: CLLocationCoordinate2D
    let address: String
    let ownerName: String
    let ownerVerified: Bool
    let price: String
    let rating: Double
    let icon: String
    let isTransportActive: Bool
    let eta: String?
    let endDate: Date?

    nonisolated static func == (lhs: MapItem, rhs: MapItem) -> Bool {
        lhs.id == rhs.id
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func fromProvider(_ provider: Provider) -> MapItem {
        let cat: MapItemCategory = switch provider.categoryID {
        case "taxi": .taxi
        case "minibus": .minibus
        case "bateau": .bateau
        case "camion": .camion
        default: .vehicule
        }
        return MapItem(
            id: "provider-\(provider.id)",
            name: provider.name,
            subtitle: provider.vehicleType,
            category: cat,
            status: provider.status,
            coordinate: provider.coordinate,
            address: "",
            ownerName: provider.name,
            ownerVerified: provider.isVerified,
            price: provider.tarif,
            rating: provider.rating,
            icon: provider.avatarSystemName,
            isTransportActive: true,
            eta: provider.status == .disponible ? "\(Int.random(in: 2...12)) min" : nil,
            endDate: nil
        )
    }

    static func fromRental(_ item: RentalItem) -> MapItem {
        let cat: MapItemCategory = switch item.category {
        case .vehicules: .vehicule
        case .bateaux: .bateau
        case .appartements, .saisonnieres: .immobilier
        }
        return MapItem(
            id: "rental-\(item.id)",
            name: item.name,
            subtitle: item.ownerName,
            category: cat,
            status: item.status,
            coordinate: item.coordinate,
            address: item.address,
            ownerName: item.ownerName,
            ownerVerified: item.ownerVerified,
            price: item.pricePerDay,
            rating: item.rating,
            icon: item.icon,
            isTransportActive: false,
            eta: nil,
            endDate: item.occupiedUntil
        )
    }

    static func fromTool(_ tool: ToolItem) -> MapItem {
        MapItem(
            id: "tool-\(tool.id)",
            name: tool.name,
            subtitle: "\(tool.brand) · \(tool.model)",
            category: .outil,
            status: tool.status,
            coordinate: tool.coordinate,
            address: tool.address,
            ownerName: tool.ownerName,
            ownerVerified: tool.ownerVerified,
            price: tool.pricePerDay,
            rating: tool.rating,
            icon: tool.icon,
            isTransportActive: false,
            eta: nil,
            endDate: tool.occupiedUntil
        )
    }
}
