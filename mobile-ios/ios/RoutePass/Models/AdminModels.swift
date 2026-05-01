import Foundation
import SwiftUI

nonisolated struct PendingValidation: Identifiable, Sendable {
    let id: String
    let name: String
    let documentType: String
    let submittedDate: Date
    let avatarSystemName: String
    let role: String
}

nonisolated struct AdminDailyStats: Sendable {
    let transactionCount: Int
    let totalAmount: String
    let commissionGenerated: String
    let pendingValidations: Int
}

nonisolated struct AdminBarData: Identifiable, Sendable {
    let id: String
    let label: String
    let value: Double
    let maxValue: Double
}

enum AdminMockData {
    static let dailyStats = AdminDailyStats(
        transactionCount: 143,
        totalAmount: "28 500 €",
        commissionGenerated: "1 425 €",
        pendingValidations: 7
    )

    static let weeklyBars: [AdminBarData] = [
        AdminBarData(id: "d1", label: "Lun", value: 850, maxValue: 1500),
        AdminBarData(id: "d2", label: "Mar", value: 1200, maxValue: 1500),
        AdminBarData(id: "d3", label: "Mer", value: 950, maxValue: 1500),
        AdminBarData(id: "d4", label: "Jeu", value: 1425, maxValue: 1500),
        AdminBarData(id: "d5", label: "Ven", value: 1100, maxValue: 1500),
        AdminBarData(id: "d6", label: "Sam", value: 750, maxValue: 1500),
        AdminBarData(id: "d7", label: "Dim", value: 450, maxValue: 1500),
    ]

    static let pendingValidations: [PendingValidation] = [
        PendingValidation(id: "pv1", name: "Marine Lambert", documentType: "Permis de conduire", submittedDate: Date().addingTimeInterval(-3600), avatarSystemName: "person.crop.circle.fill", role: "Prestataire taxi"),
        PendingValidation(id: "pv2", name: "Vincent Moreau", documentType: "Carte grise véhicule", submittedDate: Date().addingTimeInterval(-7200), avatarSystemName: "person.crop.circle.fill", role: "Prestataire minibus"),
        PendingValidation(id: "pv3", name: "Catherine Girard", documentType: "Titre de propriété", submittedDate: Date().addingTimeInterval(-14400), avatarSystemName: "person.crop.circle.fill", role: "Propriétaire"),
        PendingValidation(id: "pv4", name: "Stéphane Leclerc", documentType: "Assurance bateau", submittedDate: Date().addingTimeInterval(-28800), avatarSystemName: "person.crop.circle.fill", role: "Prestataire bateau"),
        PendingValidation(id: "pv5", name: "Nathalie Fournier", documentType: "Licence transport", submittedDate: Date().addingTimeInterval(-43200), avatarSystemName: "person.crop.circle.fill", role: "Prestataire fret"),
        PendingValidation(id: "pv6", name: "Olivier Rousseau", documentType: "Permis de conduire", submittedDate: Date().addingTimeInterval(-57600), avatarSystemName: "person.crop.circle.fill", role: "Prestataire taxi"),
        PendingValidation(id: "pv7", name: "Émilie Blanc", documentType: "Bail locatif", submittedDate: Date().addingTimeInterval(-86400), avatarSystemName: "person.crop.circle.fill", role: "Propriétaire"),
    ]
}
