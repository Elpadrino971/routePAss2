import SwiftUI

struct ProprietaireOutilsView: View {
    @State private var viewModel = ToolViewModel()
    @State private var showSettings: Bool = false
    @State private var selectedOwnerTool: OwnerTool?

    var body: some View {
        ScrollView {
            VStack(spacing: RPTheme.Spacing.lg) {
                RPSectionHeader(
                    title: "Mes outils",
                    subtitle: "Gérez votre catalogue",
                    icon: "wrench.and.screwdriver.fill"
                )

                catalogueSection
                revenueSection
                planningSection
                addToolButton
            }
            .padding(.bottom, 80)
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $viewModel.showAddTool) {
            AddToolSheet(onDismiss: { viewModel.showAddTool = false })
        }
        .sheet(item: $selectedOwnerTool) { ownerTool in
            OwnerToolDetailSheet(ownerTool: ownerTool)
        }
    }

    private var catalogueSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            HStack {
                Text("Catalogue")
                    .font(.system(.headline, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)
                Spacer()
                Text("\(viewModel.ownerTools.count) outils")
                    .font(.system(.caption, design: .default, weight: .medium))
                    .foregroundStyle(RPTheme.textSecondary)
            }
            .padding(.horizontal, RPTheme.Spacing.md)

            ScrollView(.horizontal) {
                HStack(spacing: RPTheme.Spacing.md) {
                    ForEach(viewModel.ownerTools) { ownerTool in
                        Button {
                            selectedOwnerTool = ownerTool
                        } label: {
                            OwnerToolCard(ownerTool: ownerTool)
                        }
                    }
                }
            }
            .contentMargins(.horizontal, 16)
            .scrollIndicators(.hidden)
        }
    }

    private var revenueSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Revenus par outil")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)
                .padding(.horizontal, RPTheme.Spacing.md)

            VStack(spacing: RPTheme.Spacing.sm) {
                ForEach(ToolMockData.toolRevenue) { data in
                    ToolRevenueRow(data: data)
                }
            }
            .padding(.horizontal, RPTheme.Spacing.md)
        }
    }

    private var planningSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Planning semaine")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)
                .padding(.horizontal, RPTheme.Spacing.md)

            VStack(spacing: RPTheme.Spacing.sm) {
                ForEach(viewModel.ownerWeekEvents) { event in
                    WeekEventRow(event: event)
                }
            }
            .padding(.horizontal, RPTheme.Spacing.md)
        }
    }

    private var addToolButton: some View {
        Button {
            viewModel.showAddTool = true
        } label: {
            HStack(spacing: RPTheme.Spacing.sm) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))
                Text("Ajouter un outil")
                    .font(.system(.body, design: .rounded, weight: .semibold))
            }
        }
        .buttonStyle(RPPrimaryButtonStyle())
        .padding(.horizontal, RPTheme.Spacing.md)
    }
}

struct OwnerToolCard: View {
    let ownerTool: OwnerTool
    @State private var appeared: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.sm) {
            Color(RPTheme.accent.opacity(0.06))
                .frame(width: 200, height: 120)
                .overlay {
                    Image(systemName: ownerTool.tool.icon)
                        .font(.system(size: 36))
                        .foregroundStyle(RPTheme.accent.opacity(0.4))
                        .allowsHitTesting(false)
                }
                .clipShape(.rect(cornerRadius: 14))
                .overlay(alignment: .topLeading) {
                    RPBadge(status: ownerTool.tool.status)
                        .scaleEffect(0.8)
                        .padding(6)
                }

            Text(ownerTool.tool.name)
                .font(.system(.subheadline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)
                .lineLimit(1)

            Text(ownerTool.monthRevenue)
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(RPTheme.accent)
            + Text(" /mois")
                .font(.system(.caption2, design: .default))
                .foregroundStyle(RPTheme.textSecondary)

            Text("\(ownerTool.reservationCount) réservations")
                .font(.system(.caption2, design: .default))
                .foregroundStyle(RPTheme.textSecondary)
        }
        .padding(10)
        .frame(width: 220)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        .shadow(color: RPTheme.cardShadow, radius: 6, x: 0, y: 2)
        .scaleEffect(appeared ? 1 : 0.95)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
}

struct ToolRevenueRow: View {
    let data: ToolRevenueData
    @State private var appeared: Bool = false
    @State private var barWidth: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.sm) {
            HStack(spacing: RPTheme.Spacing.sm) {
                Image(systemName: data.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(RPTheme.accent)
                    .frame(width: 28)

                Text(data.toolName)
                    .font(.system(.subheadline, design: .default, weight: .medium))
                    .foregroundStyle(RPTheme.textPrimary)

                Spacer()

                Text(data.revenue)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(RPTheme.accent)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.tertiarySystemFill))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(RPTheme.accent)
                        .frame(width: barWidth, height: 6)
                }
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                        barWidth = geo.size.width * data.percentage
                    }
                }
            }
            .frame(height: 6)
        }
        .padding(RPTheme.Spacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 14))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
}
