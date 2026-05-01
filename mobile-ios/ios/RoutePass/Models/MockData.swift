import Foundation

nonisolated struct RPCardItem: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let price: String
    let status: RPStatus
    let imageName: String        // SF symbol fallback
    let imageURL: String?        // photo distante (Unsplash) optionnelle
    let category: RPCategory
    let isPrincipal: Bool        // badge rouge "Principal" en top-right
    let availableAt: String?     // ex. "Libre le 15 Avril"
}

nonisolated enum RPCategory: String, CaseIterable, Sendable {
    case transport = "Transport"
    case location = "Location"
    case immobilier = "Immobilier"
}

enum MockData {
    static let featuredItems: [RPCardItem] = [
        RPCardItem(
            id: "f1",
            title: "Loft Marais",
            subtitle: "120m² · Paris 3ème",
            price: "2 400€/mois",
            status: .disponible,
            imageName: "building.2.fill",
            imageURL: "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=900&q=80",
            category: .immobilier,
            isPrincipal: false,
            availableAt: "Libre le 15 Avril"
        ),
        RPCardItem(
            id: "f2",
            title: "Sunseeker 42",
            subtitle: "Yacht · Cannes",
            price: "2400€/jour",
            status: .disponible,
            imageName: "ferry.fill",
            imageURL: "https://images.unsplash.com/photo-1567899378494-47b22a2ae96a?auto=format&fit=crop&w=900&q=80",
            category: .location,
            isPrincipal: false,
            availableAt: nil
        ),
        RPCardItem(
            id: "f3",
            title: "Tesla Model 3",
            subtitle: "Location longue durée",
            price: "890€/mois",
            status: .disponible,
            imageName: "bolt.car.fill",
            imageURL: "https://images.unsplash.com/photo-1560958089-b8a1929cea89?auto=format&fit=crop&w=900&q=80",
            category: .location,
            isPrincipal: false,
            availableAt: nil
        ),
    ]

    static let recentItems: [RPCardItem] = [
        RPCardItem(
            id: "r1",
            title: "Mercedes Classe E",
            subtitle: "Berline premium · Paris",
            price: "85€/h",
            status: .disponible,
            imageName: "car.fill",
            imageURL: "https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=900&q=80",
            category: .transport,
            isPrincipal: true,
            availableAt: nil
        ),
        RPCardItem(
            id: "r2",
            title: "Studio Rivoli",
            subtitle: "35m² · Paris 1er",
            price: "1 200€/mois",
            status: .nettoyage,
            imageName: "house.fill",
            imageURL: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=900&q=80",
            category: .immobilier,
            isPrincipal: true,
            availableAt: "Libre le 12 Avril"
        ),
    ]

    static let transportItems: [RPCardItem] = [
        RPCardItem(id: "t1", title: "Mercedes Classe E", subtitle: "Berline premium",       price: "85€/h",  status: .disponible, imageName: "car.fill",          imageURL: "https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=900&q=80", category: .transport, isPrincipal: false, availableAt: nil),
        RPCardItem(id: "t2", title: "BMW Série 7",       subtitle: "VTC haut de gamme",    price: "95€/h",  status: .occupe,     imageName: "car.side.fill",     imageURL: nil, category: .transport, isPrincipal: false, availableAt: nil),
        RPCardItem(id: "t3", title: "Van Mercedes V-Class", subtitle: "Jusqu'à 7 passagers", price: "120€/h", status: .disponible, imageName: "bus.fill",         imageURL: nil, category: .transport, isPrincipal: false, availableAt: nil),
        RPCardItem(id: "t4", title: "Audi A8",           subtitle: "Service aéroport",     price: "150€",   status: .nettoyage,  imageName: "airplane.departure", imageURL: nil, category: .transport, isPrincipal: false, availableAt: "Libre à 14h30"),
        RPCardItem(id: "t5", title: "Range Rover",       subtitle: "SUV de luxe",           price: "110€/h", status: .disponible, imageName: "suv.side.fill",     imageURL: nil, category: .transport, isPrincipal: false, availableAt: nil),
    ]

    static let locationItems: [RPCardItem] = [
        RPCardItem(id: "l1", title: "Tesla Model 3",    subtitle: "Électrique",   price: "890€/mois",  status: .disponible, imageName: "bolt.car.fill",                imageURL: nil, category: .location, isPrincipal: false, availableAt: nil),
        RPCardItem(id: "l2", title: "Porsche Taycan",   subtitle: "Électrique",   price: "1 500€/mois", status: .occupe,     imageName: "car.top.radiowaves.front.fill", imageURL: nil, category: .location, isPrincipal: false, availableAt: nil),
        RPCardItem(id: "l3", title: "BMW X5",           subtitle: "SUV",           price: "1 200€/mois", status: .nettoyage,  imageName: "car.fill",                     imageURL: nil, category: .location, isPrincipal: false, availableAt: nil),
        RPCardItem(id: "l4", title: "Audi e-tron GT",   subtitle: "Électrique",   price: "1 600€/mois", status: .disponible, imageName: "bolt.car.fill",                imageURL: nil, category: .location, isPrincipal: false, availableAt: nil),
        RPCardItem(id: "l5", title: "Mercedes EQS",     subtitle: "Électrique",   price: "1 800€/mois", status: .libreLe,    imageName: "car.side.fill",                imageURL: nil, category: .location, isPrincipal: false, availableAt: "Libre le 20 Avril"),
        RPCardItem(id: "l6", title: "Volvo XC90",       subtitle: "SUV Hybride",   price: "1 100€/mois", status: .disponible, imageName: "suv.side.fill",                imageURL: nil, category: .location, isPrincipal: false, availableAt: nil),
    ]

    static let immobilierItems: [RPCardItem] = [
        RPCardItem(id: "i1", title: "Loft Marais",          subtitle: "120m² · Paris 3ème",       price: "2 400€/mois",  status: .libreLe,    imageName: "building.2.fill", imageURL: nil, category: .immobilier, isPrincipal: false, availableAt: "Libre le 15 Avril"),
        RPCardItem(id: "i2", title: "Penthouse Trocadéro",  subtitle: "250m² · Paris 16ème",      price: "8 500€/mois",  status: .disponible, imageName: "building.fill",    imageURL: nil, category: .immobilier, isPrincipal: false, availableAt: nil),
        RPCardItem(id: "i3", title: "Studio Saint-Germain", subtitle: "35m² · Paris 6ème",        price: "1 200€/mois",  status: .occupe,     imageName: "house.fill",       imageURL: nil, category: .immobilier, isPrincipal: false, availableAt: nil),
        RPCardItem(id: "i4", title: "Villa Neuilly",        subtitle: "300m² · Jardin",            price: "12 000€/mois", status: .nettoyage,  imageName: "house.and.flag.fill", imageURL: nil, category: .immobilier, isPrincipal: false, availableAt: "Libre le 25 Avril"),
        RPCardItem(id: "i5", title: "Appartement Opéra",    subtitle: "85m² · Paris 9ème",        price: "2 800€/mois",  status: .disponible, imageName: "building.2.fill",  imageURL: nil, category: .immobilier, isPrincipal: false, availableAt: nil),
    ]

    static let accountOptions: [AccountOption] = [
        AccountOption(id: "a1", title: "Mes réservations",      icon: "calendar.badge.clock",    count: 3),
        AccountOption(id: "a2", title: "Mes favoris",            icon: "heart.fill",              count: 12),
        AccountOption(id: "a3", title: "Historique",             icon: "clock.arrow.circlepath", count: nil),
        AccountOption(id: "a4", title: "Moyens de paiement",     icon: "creditcard.fill",         count: nil),
        AccountOption(id: "a5", title: "Documents",              icon: "doc.text.fill",           count: 5),
        AccountOption(id: "a6", title: "Paramètres",             icon: "gearshape.fill",          count: nil),
        AccountOption(id: "a7", title: "Aide & Support",         icon: "questionmark.circle.fill", count: nil),
    ]
}

nonisolated struct AccountOption: Identifiable, Sendable {
    let id: String
    let title: String
    let icon: String
    let count: Int?
}
