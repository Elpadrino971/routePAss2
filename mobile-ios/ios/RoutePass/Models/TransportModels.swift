import Foundation
import SwiftUI
import CoreLocation

nonisolated struct TransportCategory: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let icon: String
    let emoji: String
    let providerCount: Int
}

nonisolated struct Provider: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let vehicleType: String
    let categoryID: String
    let rating: Double
    let reviewCount: Int
    let tarif: String
    let status: RPStatus
    let isVerified: Bool
    let avatarSystemName: String
    let distanceKm: Double?
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

nonisolated struct Trip: Identifiable, Sendable {
    let id: String
    let providerName: String
    let serviceName: String
    let amount: String
    let commission: String
    let netAmount: String
    let code: String
    let timestamp: Date
}

nonisolated struct DailySummary: Sendable {
    let totalEarnings: String
    let tripCount: Int
    let trips: [Trip]
}

enum TransportMockData {
    static let categories: [TransportCategory] = [
        TransportCategory(id: "taxi", name: "Taxi", icon: "car.fill", emoji: "🚕", providerCount: 24),
        TransportCategory(id: "minibus", name: "Minibus", icon: "bus.fill", emoji: "🚌", providerCount: 12),
        TransportCategory(id: "bateau", name: "Bateau", icon: "ferry.fill", emoji: "🛥️", providerCount: 8),
        TransportCategory(id: "camion", name: "Fret", icon: "shippingbox.fill", emoji: "🚛", providerCount: 15),
    ]

    static let providers: [Provider] = [
        Provider(id: "p1", name: "Laurent Dupont", vehicleType: "Toyota Corolla · Taxi", categoryID: "taxi", rating: 4.8, reviewCount: 342, tarif: "12 €", status: .disponible, isVerified: true, avatarSystemName: "person.crop.circle.fill", distanceKm: 0.8, latitude: 48.8566, longitude: 2.3522),
        Provider(id: "p2", name: "Philippe Martin", vehicleType: "Mercedes Sprinter · Minibus", categoryID: "minibus", rating: 4.6, reviewCount: 128, tarif: "18 €", status: .disponible, isVerified: true, avatarSystemName: "person.crop.circle.fill", distanceKm: 1.2, latitude: 48.8606, longitude: 2.3376),
        Provider(id: "p3", name: "Nicolas Lefèvre", vehicleType: "Hyundai Accent · Taxi", categoryID: "taxi", rating: 4.9, reviewCount: 567, tarif: "10 €", status: .occupe, isVerified: true, avatarSystemName: "person.crop.circle.fill", distanceKm: 2.5, latitude: 48.8738, longitude: 2.2950),
        Provider(id: "p4", name: "Marc Fontaine", vehicleType: "Vedette rapide · Bateau", categoryID: "bateau", rating: 4.5, reviewCount: 89, tarif: "35 €", status: .disponible, isVerified: false, avatarSystemName: "person.crop.circle.fill", distanceKm: nil, latitude: 48.8584, longitude: 2.2945),
        Provider(id: "p5", name: "Julien Moreau", vehicleType: "Renault Master · Fret", categoryID: "camion", rating: 4.7, reviewCount: 201, tarif: "45 €", status: .nettoyage, isVerified: true, avatarSystemName: "person.crop.circle.fill", distanceKm: 3.1, latitude: 48.8867, longitude: 2.3431),
        Provider(id: "p6", name: "Thomas Bernard", vehicleType: "Peugeot 301 · Taxi", categoryID: "taxi", rating: 4.4, reviewCount: 156, tarif: "11 €", status: .disponible, isVerified: true, avatarSystemName: "person.crop.circle.fill", distanceKm: 0.5, latitude: 48.8530, longitude: 2.3499),
        Provider(id: "p7", name: "Sophie Lemaire", vehicleType: "Toyota HiAce · Minibus", categoryID: "minibus", rating: 4.8, reviewCount: 312, tarif: "22 €", status: .disponible, isVerified: true, avatarSystemName: "person.crop.circle.fill", distanceKm: 1.8, latitude: 48.8450, longitude: 2.3600),
        Provider(id: "p8", name: "Pierre Gauthier", vehicleType: "Vedette rapide · Bateau", categoryID: "bateau", rating: 4.3, reviewCount: 45, tarif: "40 €", status: .disponible, isVerified: true, avatarSystemName: "person.crop.circle.fill", distanceKm: nil, latitude: 48.8620, longitude: 2.2870),
    ]

    static let dailySummary = DailySummary(
        totalEarnings: "185 €",
        tripCount: 7,
        trips: [
            Trip(id: "tr1", providerName: "Client A", serviceName: "Aéroport → Centre-ville", amount: "35 €", commission: "1,75 €", netAmount: "33,25 €", code: "4829", timestamp: Date().addingTimeInterval(-3600)),
            Trip(id: "tr2", providerName: "Client B", serviceName: "Gare → Plateau", amount: "18 €", commission: "0,90 €", netAmount: "17,10 €", code: "7163", timestamp: Date().addingTimeInterval(-7200)),
            Trip(id: "tr3", providerName: "Client C", serviceName: "Marché → Résidence", amount: "12 €", commission: "0,60 €", netAmount: "11,40 €", code: "3941", timestamp: Date().addingTimeInterval(-10800)),
            Trip(id: "tr4", providerName: "Client D", serviceName: "Hôtel → Port", amount: "40 €", commission: "2,00 €", netAmount: "38,00 €", code: "5082", timestamp: Date().addingTimeInterval(-14400)),
            Trip(id: "tr5", providerName: "Client E", serviceName: "Campus → Centre commercial", amount: "22 €", commission: "1,10 €", netAmount: "20,90 €", code: "6217", timestamp: Date().addingTimeInterval(-18000)),
            Trip(id: "tr6", providerName: "Client F", serviceName: "Clinique → Domicile", amount: "28 €", commission: "1,40 €", netAmount: "26,60 €", code: "1548", timestamp: Date().addingTimeInterval(-21600)),
            Trip(id: "tr7", providerName: "Client G", serviceName: "Stade → Corniche", amount: "18 €", commission: "0,90 €", netAmount: "17,10 €", code: "9374", timestamp: Date().addingTimeInterval(-25200)),
        ]
    )
}
