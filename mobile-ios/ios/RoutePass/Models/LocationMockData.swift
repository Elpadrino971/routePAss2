import Foundation
import SwiftUI

enum LocationMockData {
    /// Photos haute qualité Unsplash dans `gallery` (utilisées par les cards et le détail).
    /// Le champ `icon` reste un SF Symbol (fallback si l'image ne charge pas).
    static let rentalItems: [RentalItem] = [
        RentalItem(
            id: "r1", name: "Tesla Model Y", description: "SUV électrique premium avec Autopilot. Intérieur cuir blanc, toit panoramique. Parfait pour les trajets urbains et les escapades weekend. Recharge complète incluse au départ.", category: .vehicules, status: .disponible,
            ownerName: "Claire Dubois", ownerVerified: true, rating: 4.9, reviewCount: 87,
            pricePerHour: "45 €", pricePerDay: "180 €", pricePerWeek: "950 €", pricePerMonth: "2 800 €",
            deposit: "1 500 €", icon: "bolt.car.fill",
            gallery: [
                "https://images.unsplash.com/photo-1620891549027-942fdc95d3f5?auto=format&fit=crop&w=1200&q=80",
                "https://images.unsplash.com/photo-1617788138017-80ad40651399?auto=format&fit=crop&w=1200&q=80",
                "https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=1200&q=80"
            ],
            features: ["Électrique", "Automatique", "GPS", "Bluetooth"],
            occupiedUntil: nil, cleaningMinutes: 30, nextAvailable: nil,
            latitude: 48.8566, longitude: 2.3522, address: "Paris 1er, Rue de Rivoli"
        ),
        RentalItem(
            id: "r2", name: "Toyota Land Cruiser", description: "4x4 robuste pour tous terrains. Climatisation, 7 places, idéal pour les longs trajets. Entretien récent, pneus neufs.", category: .vehicules, status: .occupe,
            ownerName: "François Mercier", ownerVerified: true, rating: 4.7, reviewCount: 134,
            pricePerHour: "35 €", pricePerDay: "150 €", pricePerWeek: "850 €", pricePerMonth: "2 400 €",
            deposit: "2 000 €", icon: "car.fill",
            gallery: [
                "https://images.unsplash.com/photo-1580414155951-08e2c2cc1bb1?auto=format&fit=crop&w=1200&q=80",
                "https://images.unsplash.com/photo-1583121274602-3e2820c69888?auto=format&fit=crop&w=1200&q=80",
                "https://images.unsplash.com/photo-1494976388531-d1058494cdd8?auto=format&fit=crop&w=1200&q=80"
            ],
            features: ["4x4", "7 places", "Diesel", "Climatisation"],
            occupiedUntil: Date().addingTimeInterval(86400 * 3), cleaningMinutes: 45, nextAvailable: "18 Avr",
            latitude: 48.8738, longitude: 2.2950, address: "Paris 16ème, Avenue Foch"
        ),
        RentalItem(
            id: "r3", name: "Bateau semi-rigide 12 places", description: "Semi-rigide motorisé de 12 places. Parfait pour les excursions en mer. Gilets de sauvetage fournis. Skipper disponible en option.", category: .bateaux, status: .disponible,
            ownerName: "Antoine Leroy", ownerVerified: true, rating: 4.6, reviewCount: 52,
            pricePerHour: "120 €", pricePerDay: "650 €", pricePerWeek: "3 500 €", pricePerMonth: "10 000 €",
            deposit: "800 €", icon: "ferry.fill",
            gallery: [
                "https://images.unsplash.com/photo-1567899378494-47b22a2ae96a?auto=format&fit=crop&w=1200&q=80",
                "https://images.unsplash.com/photo-1542558817-5d8d717a85e9?auto=format&fit=crop&w=1200&q=80",
                "https://images.unsplash.com/photo-1502933691298-84fc14542831?auto=format&fit=crop&w=1200&q=80"
            ],
            features: ["12 places", "Motorisé", "Gilets inclus", "GPS marin"],
            occupiedUntil: nil, cleaningMinutes: 60, nextAvailable: nil,
            latitude: 43.2965, longitude: 5.3698, address: "Vieux-Port, Marseille"
        ),
        RentalItem(
            id: "r4", name: "Appartement Marais", description: "Bel appartement meublé au cœur du Marais. 2 chambres, salon lumineux, cuisine équipée. Vue sur cour arborée. Wifi haut débit, gardiennage 24h.", category: .appartements, status: .nettoyage,
            ownerName: "Isabelle Renard", ownerVerified: true, rating: 4.8, reviewCount: 203,
            pricePerHour: nil, pricePerDay: "180 €", pricePerWeek: "950 €", pricePerMonth: "2 400 €",
            deposit: "2 400 €", icon: "building.2.fill",
            gallery: [
                "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1200&q=80",
                "https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=1200&q=80",
                "https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=1200&q=80"
            ],
            features: ["2 chambres", "Meublé", "Wifi", "Gardiennage"],
            occupiedUntil: nil, cleaningMinutes: 120, nextAvailable: nil,
            latitude: 48.8606, longitude: 2.3622, address: "Paris 3ème, Rue de Turenne"
        ),
        RentalItem(
            id: "r5", name: "Villa Côte d'Azur", description: "Villa de standing face à la mer. 4 chambres climatisées, piscine privée, jardin méditerranéen. Personnel de maison inclus. Idéal vacances en famille.", category: .saisonnieres, status: .libreLe,
            ownerName: "Jean-Pierre Vasseur", ownerVerified: true, rating: 4.9, reviewCount: 76,
            pricePerHour: nil, pricePerDay: "450 €", pricePerWeek: "2 800 €", pricePerMonth: "8 500 €",
            deposit: "3 000 €", icon: "house.and.flag.fill",
            gallery: [
                "https://images.unsplash.com/photo-1613977257363-707ba9348227?auto=format&fit=crop&w=1200&q=80",
                "https://images.unsplash.com/photo-1582268611958-ebfd161ef9cf?auto=format&fit=crop&w=1200&q=80",
                "https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?auto=format&fit=crop&w=1200&q=80"
            ],
            features: ["4 chambres", "Piscine", "Bord de mer", "Personnel"],
            occupiedUntil: Date().addingTimeInterval(86400 * 7), cleaningMinutes: 180, nextAvailable: "22 Avr",
            latitude: 43.5528, longitude: 7.0174, address: "Antibes, Bord de Mer"
        ),
        RentalItem(
            id: "r6", name: "Scooter Yamaha NMAX", description: "Scooter 125cc économique et maniable. Parfait pour la ville. Casque et antivol fournis. Consommation minimale.", category: .vehicules, status: .disponible,
            ownerName: "Maxime Perrin", ownerVerified: false, rating: 4.4, reviewCount: 38,
            pricePerHour: "8 €", pricePerDay: "35 €", pricePerWeek: "180 €", pricePerMonth: "450 €",
            deposit: "300 €", icon: "scooter",
            gallery: [
                "https://images.unsplash.com/photo-1591769225440-811ad7d6eab3?auto=format&fit=crop&w=1200&q=80",
                "https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?auto=format&fit=crop&w=1200&q=80"
            ],
            features: ["125cc", "Casque inclus", "Économique", "Antivol"],
            occupiedUntil: nil, cleaningMinutes: 15, nextAvailable: nil,
            latitude: 48.8530, longitude: 2.3499, address: "Paris 5ème, Rue Mouffetard"
        ),
        RentalItem(
            id: "r7", name: "Vedette rapide 8 places", description: "Vedette de luxe pour excursions maritimes. Cabine climatisée, sono, glacière. Idéal pour événements et sorties en groupe.", category: .bateaux, status: .disponible,
            ownerName: "Éric Blanchard", ownerVerified: true, rating: 4.8, reviewCount: 29,
            pricePerHour: "200 €", pricePerDay: "1 200 €", pricePerWeek: "6 500 €", pricePerMonth: "18 000 €",
            deposit: "2 500 €", icon: "sailboat.fill",
            gallery: [
                "https://images.unsplash.com/photo-1589989993155-c5b1cea4775b?auto=format&fit=crop&w=1200&q=80",
                "https://images.unsplash.com/photo-1493612276216-ee3925520721?auto=format&fit=crop&w=1200&q=80"
            ],
            features: ["8 places", "Climatisée", "Sono", "Glacière"],
            occupiedUntil: nil, cleaningMinutes: 90, nextAvailable: nil,
            latitude: 43.6961, longitude: 7.2716, address: "Port de Nice"
        ),
        RentalItem(
            id: "r8", name: "Studio meublé Saint-Germain", description: "Studio moderne tout équipé à Saint-Germain-des-Prés. Idéal pour expatriés et séjours professionnels. Proche restaurants et métro.", category: .appartements, status: .disponible,
            ownerName: "Catherine Girard", ownerVerified: true, rating: 4.5, reviewCount: 145,
            pricePerHour: nil, pricePerDay: "95 €", pricePerWeek: "550 €", pricePerMonth: "1 600 €",
            deposit: "1 600 €", icon: "house.fill",
            gallery: [
                "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1200&q=80",
                "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=1200&q=80"
            ],
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
