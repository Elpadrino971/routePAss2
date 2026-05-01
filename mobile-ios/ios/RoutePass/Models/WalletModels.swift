import Foundation
import SwiftUI

nonisolated struct WalletTransaction: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let amount: String
    let isPositive: Bool
    let type: TransactionType
    let status: TransactionStatus
    let timestamp: Date
    let reference: String
}

nonisolated enum TransactionType: String, Sendable {
    case transport
    case location
    case immobilier
    case withdrawal
    case commission

    var icon: String {
        switch self {
        case .transport: "car.fill"
        case .location: "key.fill"
        case .immobilier: "building.2.fill"
        case .withdrawal: "arrow.down.to.line"
        case .commission: "percent"
        }
    }

    var color: Color {
        switch self {
        case .transport: .blue
        case .location: .purple
        case .immobilier: .orange
        case .withdrawal: .green
        case .commission: Color(red: 142/255, green: 142/255, blue: 147/255)
        }
    }
}

nonisolated enum TransactionStatus: String, Sendable {
    case completed = "Effectué"
    case pending = "En attente"
    case failed = "Échoué"

    var color: Color {
        switch self {
        case .completed: .green
        case .pending: .orange
        case .failed: .red
        }
    }
}

nonisolated struct RevenuePoint: Identifiable, Sendable {
    let id: String
    let day: Int
    let amount: Double
}

enum WalletMockData {
    static let availableBalance: String = "2 475 €"
    static let pendingBalance: String = "320 €"
    static let monthlyRevenue: String = "12 450 €"

    static let revenuePoints: [RevenuePoint] = (1...30).map { day in
        RevenuePoint(
            id: "rp\(day)",
            day: day,
            amount: Double.random(in: 250...950)
        )
    }

    static let transactions: [WalletTransaction] = [
        WalletTransaction(id: "w1", title: "Course taxi", subtitle: "Laurent Dupont", amount: "+35 €", isPositive: true, type: .transport, status: .completed, timestamp: Date().addingTimeInterval(-1800), reference: "RP-2024-48291"),
        WalletTransaction(id: "w2", title: "Commission plateforme", subtitle: "5% sur course", amount: "-1,75 €", isPositive: false, type: .commission, status: .completed, timestamp: Date().addingTimeInterval(-1800), reference: "RP-COM-48291"),
        WalletTransaction(id: "w3", title: "Location Tesla Model 3", subtitle: "7 jours", amount: "+890 €", isPositive: true, type: .location, status: .completed, timestamp: Date().addingTimeInterval(-7200), reference: "RP-2024-47832"),
        WalletTransaction(id: "w4", title: "Virement bancaire", subtitle: "Vers compte •••4521", amount: "-1 500 €", isPositive: false, type: .withdrawal, status: .completed, timestamp: Date().addingTimeInterval(-86400), reference: "RP-VIR-00312"),
        WalletTransaction(id: "w5", title: "Loyer appartement", subtitle: "Loft Marais · Mois de mars", amount: "+2 400 €", isPositive: true, type: .immobilier, status: .completed, timestamp: Date().addingTimeInterval(-172800), reference: "RP-2024-46100"),
        WalletTransaction(id: "w6", title: "Course minibus", subtitle: "Philippe Martin", amount: "+18 €", isPositive: true, type: .transport, status: .pending, timestamp: Date().addingTimeInterval(-3600), reference: "RP-2024-48290"),
        WalletTransaction(id: "w7", title: "Location bateau", subtitle: "Vedette rapide · 3h", amount: "+600 €", isPositive: true, type: .location, status: .completed, timestamp: Date().addingTimeInterval(-259200), reference: "RP-2024-45800"),
        WalletTransaction(id: "w8", title: "Commission plateforme", subtitle: "5% sur location", amount: "-44,50 €", isPositive: false, type: .commission, status: .completed, timestamp: Date().addingTimeInterval(-7200), reference: "RP-COM-47832"),
    ]
}
