import Foundation

nonisolated struct RPCardItem: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let price: String
    let status: RPStatus
    let imageName: String
    let category: RPCategory
}

nonisolated enum RPCategory: String, CaseIterable, Sendable {
    case transport = "Transport"
    case location = "Location"
    case immobilier = "Immobilier"
}

enum MockData {
    static let featuredItems: [RPCardItem] = [
        RPCardItem(id: "f1", title: "Mercedes Classe E", subtitle: "Berline premium avec chauffeur", price: "85€/h", status: .disponible, imageName: "car.fill", category: .transport),
        RPCardItem(id: "f2", title: "Loft Marais", subtitle: "120m² · Paris 3ème", price: "2 400€/mois", status: .libreLe, imageName: "building.2.fill", category: .immobilier),
        RPCardItem(id: "f3", title: "Tesla Model 3", subtitle: "Location longue durée", price: "890€/mois", status: .disponible, imageName: "bolt.car.fill", category: .location),
    ]

    static let transportItems: [RPCardItem] = [
        RPCardItem(id: "t1", title: "Mercedes Classe E", subtitle: "Berline premium avec chauffeur", price: "85€/h", status: .disponible, imageName: "car.fill", category: .transport),
        RPCardItem(id: "t2", title: "BMW Série 7", subtitle: "VTC haut de gamme", price: "95€/h", status: .occupe, imageName: "car.side.fill", category: .transport),
        RPCardItem(id: "t3", title: "Van Mercedes V-Class", subtitle: "Jusqu'à 7 passagers", price: "120€/h", status: .disponible, imageName: "bus.fill", category: .transport),
        RPCardItem(id: "t4", title: "Audi A8", subtitle: "Service aéroport premium", price: "150€", status: .nettoyage, imageName: "airplane.departure", category: .transport),
        RPCardItem(id: "t5", title: "Range Rover", subtitle: "SUV de luxe", price: "110€/h", status: .disponible, imageName: "suv.side.fill", category: .transport),
    ]

    static let locationItems: [RPCardItem] = [
        RPCardItem(id: "l1", title: "Tesla Model 3", subtitle: "Électrique · Automatique", price: "890€/mois", status: .disponible, imageName: "bolt.car.fill", category: .location),
        RPCardItem(id: "l2", title: "Porsche Taycan", subtitle: "Électrique · Sport", price: "1 500€/mois", status: .occupe, imageName: "car.top.radiowaves.front.fill", category: .location),
        RPCardItem(id: "l3", title: "BMW X5", subtitle: "SUV · Diesel", price: "1 200€/mois", status: .nettoyage, imageName: "car.fill", category: .location),
        RPCardItem(id: "l4", title: "Audi e-tron GT", subtitle: "Électrique · Premium", price: "1 600€/mois", status: .disponible, imageName: "bolt.car.fill", category: .location),
        RPCardItem(id: "l5", title: "Mercedes EQS", subtitle: "Électrique · Luxe", price: "1 800€/mois", status: .libreLe, imageName: "car.side.fill", category: .location),
        RPCardItem(id: "l6", title: "Volvo XC90", subtitle: "SUV · Hybride", price: "1 100€/mois", status: .disponible, imageName: "suv.side.fill", category: .location),
    ]

    static let immobilierItems: [RPCardItem] = [
        RPCardItem(id: "i1", title: "Loft Marais", subtitle: "120m² · Paris 3ème · 2 ch.", price: "2 400€/mois", status: .libreLe, imageName: "building.2.fill", category: .immobilier),
        RPCardItem(id: "i2", title: "Penthouse Trocadéro", subtitle: "250m² · Paris 16ème · 4 ch.", price: "8 500€/mois", status: .disponible, imageName: "building.fill", category: .immobilier),
        RPCardItem(id: "i3", title: "Studio Saint-Germain", subtitle: "35m² · Paris 6ème · Meublé", price: "1 200€/mois", status: .occupe, imageName: "house.fill", category: .immobilier),
        RPCardItem(id: "i4", title: "Villa Neuilly", subtitle: "300m² · Jardin · 5 ch.", price: "12 000€/mois", status: .nettoyage, imageName: "house.and.flag.fill", category: .immobilier),
        RPCardItem(id: "i5", title: "Appartement Opéra", subtitle: "85m² · Paris 9ème · 2 ch.", price: "2 800€/mois", status: .disponible, imageName: "building.2.fill", category: .immobilier),
    ]

    static let accountOptions: [AccountOption] = [
        AccountOption(id: "a1", title: "Mes réservations", icon: "calendar.badge.clock", count: 3),
        AccountOption(id: "a2", title: "Mes favoris", icon: "heart.fill", count: 12),
        AccountOption(id: "a3", title: "Historique", icon: "clock.arrow.circlepath", count: nil),
        AccountOption(id: "a4", title: "Moyens de paiement", icon: "creditcard.fill", count: nil),
        AccountOption(id: "a5", title: "Documents", icon: "doc.text.fill", count: 5),
        AccountOption(id: "a6", title: "Paramètres", icon: "gearshape.fill", count: nil),
        AccountOption(id: "a7", title: "Aide & Support", icon: "questionmark.circle.fill", count: nil),
    ]
}

nonisolated struct AccountOption: Identifiable, Sendable {
    let id: String
    let title: String
    let icon: String
    let count: Int?
}
