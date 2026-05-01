import Foundation
import SwiftUI

enum LocationMockData {
    static let rentalItems: [RentalItem] = [
        RentalItem(
            id: "r1", name: "Tesla Model Y", description: "SUV électrique premium avec Autopilot. Intérieur cuir blanc, toit panoramique. Parfait pour les trajets urbains et les escapades weekend. Recharge complète incluse au départ.", category: .vehicules, status: .disponible,
            ownerName: "Claire Dubois", ownerVerified: true, rating: 4.9, reviewCount: 87,
            pricePerHour: "45 €", pricePerDay: "180 €", pricePerWeek: "950 €", pricePerMonth: "2 800 €",
            deposit: "1 500 €", icon: "bolt.car.fill",
            gallery: ["bolt.car.fill", "car.top.radiowaves.front.fill", "steeringwheel", "fuelpump.fill"],
            features: ["Électrique", "Automatique", "GPS", "Bluetooth"],
            occupiedUntil: nil, cleaningMinutes: 30, nextAvailable: nil,
            latitude: 48.8566, longitude: 2.3522, address: "Paris 1er, Rue de Rivoli"
        ),
        RentalItem(
            id: "r2", name: "Toyota Land Cruiser", description: "4x4 robuste pour tous terrains. Climatisation, 7 places, idéal pour les longs trajets. Entretien récent, pneus neufs.", category: .vehicules, status: .occupe,
            ownerName: "François Mercier", ownerVerified: true, rating: 4.7, reviewCount: 134,
            pricePerHour: "35 €", pricePerDay: "150 €", pricePerWeek: "850 €", pricePerMonth: "2 400 €",
            deposit: "2 000 €", icon: "car.fill",
            gallery: ["car.fill", "car.side.fill", "suv.side.fill", "gauge.open.with.lines.needle.33percent"],
            features: ["4x4", "7 places", "Diesel", "Climatisation"],
            occupiedUntil: Date().addingTimeInterval(86400 * 3), cleaningMinutes: 45, nextAvailable: "18 Avr",
            latitude: 48.8738, longitude: 2.2950, address: "Paris 16ème, Avenue Foch"
        ),
        RentalItem(
            id: "r3", name: "Bateau semi-rigide 12 places", description: "Semi-rigide motorisé de 12 places. Parfait pour les excursions en mer. Gilets de sauvetage fournis. Skipper disponible en option.", category: .bateaux, status: .disponible,
            ownerName: "Antoine Leroy", ownerVerified: true, rating: 4.6, reviewCount: 52,
            pricePerHour: "120 €", pricePerDay: "650 €", pricePerWeek: "3 500 €", pricePerMonth: "10 000 €",
            deposit: "800 €", icon: "ferry.fill",
            gallery: ["ferry.fill", "water.waves", "sun.max.fill", "figure.sailing"],
            features: ["12 places", "Motorisé", "Gilets inclus", "GPS marin"],
            occupiedUntil: nil, cleaningMinutes: 60, nextAvailable: nil,
            latitude: 43.2965, longitude: 5.3698, address: "Vieux-Port, Marseille"
        ),
        RentalItem(
            id: "r4", name: "Appartement Marais", description: "Bel appartement meublé au cœur du Marais. 2 chambres, salon lumineux, cuisine équipée. Vue sur cour arborée. Wifi haut débit, gardiennage 24h.", category: .appartements, status: .nettoyage,
            ownerName: "Isabelle Renard", ownerVerified: true, rating: 4.8, reviewCount: 203,
            pricePerHour: nil, pricePerDay: "180 €", pricePerWeek: "950 €", pricePerMonth: "2 400 €",
            deposit: "2 400 €", icon: "building.2.fill",
            gallery: ["building.2.fill", "bed.double.fill", "sofa.fill", "fork.knife"],
            features: ["2 chambres", "Meublé", "Wifi", "Gardiennage"],
            occupiedUntil: nil, cleaningMinutes: 120, nextAvailable: nil,
            latitude: 48.8606, longitude: 2.3622, address: "Paris 3ème, Rue de Turenne"
        ),
        RentalItem(
            id: "r5", name: "Villa Côte d'Azur", description: "Villa de standing face à la mer. 4 chambres climatisées, piscine privée, jardin méditerranéen. Personnel de maison inclus. Idéal vacances en famille.", category: .saisonnieres, status: .libreLe,
            ownerName: "Jean-Pierre Vasseur", ownerVerified: true, rating: 4.9, reviewCount: 76,
            pricePerHour: nil, pricePerDay: "450 €", pricePerWeek: "2 800 €", pricePerMonth: "8 500 €",
            deposit: "3 000 €", icon: "house.and.flag.fill",
            gallery: ["house.and.flag.fill", "water.waves", "figure.pool.swim", "tree.fill"],
            features: ["4 chambres", "Piscine", "Bord de mer", "Personnel"],
            occupiedUntil: Date().addingTimeInterval(86400 * 7), cleaningMinutes: 180, nextAvailable: "22 Avr",
            latitude: 43.5528, longitude: 7.0174, address: "Antibes, Bord de Mer"
        ),
        RentalItem(
            id: "r6", name: "Scooter Yamaha NMAX", description: "Scooter 125cc économique et maniable. Parfait pour la ville. Casque et antivol fournis. Consommation minimale.", category: .vehicules, status: .disponible,
            ownerName: "Maxime Perrin", ownerVerified: false, rating: 4.4, reviewCount: 38,
            pricePerHour: "8 €", pricePerDay: "35 €", pricePerWeek: "180 €", pricePerMonth: "450 €",
            deposit: "300 €", icon: "scooter",
            gallery: ["scooter", "helmet.fill", "fuelpump.fill", "location.fill"],
            features: ["125cc", "Casque inclus", "Économique", "Antivol"],
            occupiedUntil: nil, cleaningMinutes: 15, nextAvailable: nil,
            latitude: 48.8530, longitude: 2.3499, address: "Paris 5ème, Rue Mouffetard"
        ),
        RentalItem(
            id: "r7", name: "Vedette rapide 8 places", description: "Vedette de luxe pour excursions maritimes. Cabine climatisée, sono, glacière. Idéal pour événements et sorties en groupe.", category: .bateaux, status: .disponible,
            ownerName: "Éric Blanchard", ownerVerified: true, rating: 4.8, reviewCount: 29,
            pricePerHour: "200 €", pricePerDay: "1 200 €", pricePerWeek: "6 500 €", pricePerMonth: "18 000 €",
            deposit: "2 500 €", icon: "sailboat.fill",
            gallery: ["sailboat.fill", "water.waves", "speaker.wave.3.fill", "sun.max.fill"],
            features: ["8 places", "Climatisée", "Sono", "Glacière"],
            occupiedUntil: nil, cleaningMinutes: 90, nextAvailable: nil,
            latitude: 43.6961, longitude: 7.2716, address: "Port de Nice"
        ),
        RentalItem(
            id: "r8", name: "Studio meublé Saint-Germain", description: "Studio moderne tout équipé à Saint-Germain-des-Prés. Idéal pour expatriés et séjours professionnels. Proche restaurants et métro.", category: .appartements, status: .disponible,
            ownerName: "Catherine Girard", ownerVerified: true, rating: 4.5, reviewCount: 145,
            pricePerHour: nil, pricePerDay: "95 €", pricePerWeek: "550 €", pricePerMonth: "1 600 €",
            deposit: "1 600 €", icon: "house.fill",
            gallery: ["house.fill", "bed.double.fill", "wifi", "bolt.fill"],
            features: ["Meublé", "Wifi fibre", "Climatisé", "Proche métro"],
            occupiedUntil: nil, cleaningMinutes: 60, nextAvailable: nil,
            latitude: 48.8534, longitude: 2.3340, address: "Paris 6ème, Rue de Seine"
        ),
    ]

    static let weekEvents: [WeekEvent] = [
        WeekEvent(id: "e1", title: "Lucas M.", day: "Lun", timeRange: "08:00 – 18:00", color: .green),
        WeekEvent(id: "e2", title: "Nettoyage", day: "Mar", timeRange: "08:00 – 10:00", color: .orange),
        WeekEvent(id: "e3", title: "Marie D.", day: "Mar", timeRange: "14:00 – 18:00", color: .green),
        WeekEvent(id: "e4", title: "Libre", day: "Mer", timeRange: "Toute la journée", color: .blue),
        WeekEvent(id: "e5", title: "Thomas B.", day: "Jeu", timeRange: "09:00 – 17:00", color: .green),
        WeekEvent(id: "e6", title: "Nicolas P.", day: "Ven", timeRange: "10:00 – 20:00", color: .green),
        WeekEvent(id: "e7", title: "Bloqué", day: "Sam", timeRange: "Toute la journée", color: .red),
        WeekEvent(id: "e8", title: "Libre", day: "Dim", timeRange: "Toute la journée", color: .blue),
    ]

    static let tenantHistory: [TenantRecord] = [
        TenantRecord(id: "th1", tenantName: "Lucas Martin", dates: "1–5 Avr 2025", amount: "900 €", rating: 5.0),
        TenantRecord(id: "th2", tenantName: "Marie Dupont", dates: "28–31 Mar 2025", amount: "540 €", rating: 4.8),
        TenantRecord(id: "th3", tenantName: "Thomas Bernard", dates: "20–27 Mar 2025", amount: "1 330 €", rating: 4.5),
        TenantRecord(id: "th4", tenantName: "Nicolas Petit", dates: "15–19 Mar 2025", amount: "720 €", rating: 4.9),
        TenantRecord(id: "th5", tenantName: "Julie Roux", dates: "8–14 Mar 2025", amount: "1 330 €", rating: 4.7),
    ]
}
