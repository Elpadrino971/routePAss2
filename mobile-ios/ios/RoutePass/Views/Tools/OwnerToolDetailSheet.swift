import SwiftUI

struct OwnerToolDetailSheet: View {
    let ownerTool: OwnerTool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RPTheme.Spacing.lg) {
                    statusSection
                    revenueCards
                    toolInfoSection
                    alertSection
                }
                .padding(.top, RPTheme.Spacing.md)
                .padding(.bottom, RPTheme.Spacing.xl)
            }
            .scrollIndicators(.hidden)
            .navigationTitle(ownerTool.tool.name)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var statusSection: some View {
        VStack(spacing: RPTheme.Spacing.md) {
            RPBadge(status: ownerTool.tool.status)
                .scaleEffect(1.3)

            Text(ownerTool.tool.name)
                .font(.system(.title3, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)

            Text("\(ownerTool.tool.brand) · \(ownerTool.tool.model)")
                .font(.system(.caption, design: .default))
                .foregroundStyle(RPTheme.textSecondary)
        }
        .padding(RPTheme.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        .shadow(color: RPTheme.cardShadow, radius: RPTheme.cardShadowRadius, x: 0, y: RPTheme.cardShadowY)
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private var revenueCards: some View {
        HStack(spacing: RPTheme.Spacing.sm) {
            revenueCard(label: "Aujourd'hui", amount: ownerTool.todayRevenue, icon: "sun.max.fill")
            revenueCard(label: "Semaine", amount: ownerTool.weekRevenue, icon: "calendar")
            revenueCard(label: "Mois", amount: ownerTool.monthRevenue, icon: "chart.bar.fill")
        }
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private func revenueCard(label: String, amount: String, icon: String) -> some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(RPTheme.accent)

            Text(amount)
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(.caption2, design: .default))
                .foregroundStyle(RPTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, RPTheme.Spacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var toolInfoSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Informations")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)

            VStack(spacing: RPTheme.Spacing.sm) {
                infoRow(label: "État", value: ownerTool.tool.condition.rawValue, color: ownerTool.tool.condition.color)
                infoRow(label: "Réservations", value: "\(ownerTool.reservationCount)")
                infoRow(label: "Revenu total", value: ownerTool.totalRevenue, color: RPTheme.accent)
                infoRow(label: "Tarif journalier", value: ownerTool.tool.pricePerDay)
                infoRow(label: "Caution", value: ownerTool.tool.deposit)
            }
        }
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private func infoRow(label: String, value: String, color: Color = RPTheme.textPrimary) -> some View {
        HStack {
            Text(label)
                .font(.system(.subheadline, design: .default))
                .foregroundStyle(RPTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .default, weight: .semibold))
                .foregroundStyle(color)
        }
        .padding(RPTheme.Spacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var alertSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.sm) {
            if ownerTool.tool.status == .occupe {
                HStack(spacing: RPTheme.Spacing.sm) {
                    Image(systemName: "clock.badge.exclamationmark.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.orange)
                    Text("En location — surveiller la restitution")
                        .font(.system(.caption, design: .default, weight: .medium))
                        .foregroundStyle(.orange)
                }
                .padding(RPTheme.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.1))
                .clipShape(.rect(cornerRadius: 12))
            }
        }
        .padding(.horizontal, RPTheme.Spacing.md)
    }
}

