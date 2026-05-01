import Foundation

nonisolated enum UserRole: String, CaseIterable, Identifiable, Sendable {
    case client = "client"
    case prestataire = "prestataire"
    case proprietaire = "proprietaire"
    case admin = "admin"

    nonisolated var id: String { rawValue }

    var title: String {
        switch self {
        case .client: "Je cherche un service"
        case .prestataire: "Je suis prestataire"
        case .proprietaire: "Je loue un bien"
        case .admin: "Administration"
        }
    }

    var icon: String {
        switch self {
        case .client: "👤"
        case .prestataire: "🚗"
        case .proprietaire: "🏠"
        case .admin: "🛡️"
        }
    }

    var subtitle: String {
        switch self {
        case .client: "Trouvez et réservez des services de transport, location et immobilier."
        case .prestataire: "Gérez vos véhicules, vos courses et vos revenus."
        case .proprietaire: "Mettez vos biens en location et suivez vos paiements."
        case .admin: "Gérez la plateforme, validez les prestataires et déclenchez les virements."
        }
    }

    var systemIcon: String {
        switch self {
        case .client: "magnifyingglass"
        case .prestataire: "car.fill"
        case .proprietaire: "key.fill"
        case .admin: "shield.checkered"
        }
    }
}
