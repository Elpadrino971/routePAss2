import SwiftUI

struct TransactionRow: View {
    let transaction: WalletTransaction

    private var timeText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: transaction.timestamp, relativeTo: Date())
    }

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(transaction.type.color.opacity(0.12))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: transaction.type.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(transaction.type.color)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.title)
                    .font(.system(.subheadline, design: .default, weight: .semibold))
                    .foregroundStyle(RPTheme.textPrimary)
                    .lineLimit(1)

                Text(transaction.subtitle)
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(transaction.amount)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(transaction.isPositive ? .green : RPTheme.textPrimary)

                HStack(spacing: 4) {
                    Circle()
                        .fill(transaction.status.color)
                        .frame(width: 6, height: 6)
                    Text(timeText)
                        .font(.system(.caption2, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                }
            }
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(transaction.title), \(transaction.amount), \(transaction.status.rawValue)")
    }
}
