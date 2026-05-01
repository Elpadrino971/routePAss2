import SwiftUI

struct AdminDashboardView: View {
    @State private var appeared: Bool = false
    @State private var showBatchSheet: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RPTheme.Spacing.lg) {
                    statsGrid
                    weeklyChart
                    validationSection
                    batchPayoutButton
                }
                .padding(.bottom, RPTheme.Spacing.xxl)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Administration")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showBatchSheet) {
                BatchPayoutSheet()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    appeared = true
                }
            }
        }
    }

    private var statsGrid: some View {
        let stats = AdminMockData.dailyStats
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            AdminStatCard(
                title: "Transactions",
                value: "\(stats.transactionCount)",
                icon: "arrow.left.arrow.right",
                color: .blue
            )
            AdminStatCard(
                title: "Volume total",
                value: stats.totalAmount,
                icon: "banknote.fill",
                color: .green
            )
            AdminStatCard(
                title: "Commission",
                value: stats.commissionGenerated,
                icon: "sparkles",
                color: RPTheme.accent,
                isHighlighted: true
            )
            AdminStatCard(
                title: "En attente",
                value: "\(stats.pendingValidations)",
                icon: "person.badge.clock.fill",
                color: .red,
                badgeCount: stats.pendingValidations
            )
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .padding(.top, RPTheme.Spacing.sm)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Commissions 7 jours")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)

            AdminBarChart(data: AdminMockData.weeklyBars)
                .frame(height: 160)
        }
        .padding(RPTheme.Spacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        .padding(.horizontal, RPTheme.Spacing.md)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
    }

    private var validationSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            HStack {
                Text("Validations en attente")
                    .font(.system(.headline, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Spacer()

                Text("\(AdminMockData.pendingValidations.count)")
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.red)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, RPTheme.Spacing.md)

            VStack(spacing: 1) {
                ForEach(AdminMockData.pendingValidations) { validation in
                    ValidationRow(validation: validation)
                }
            }
            .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
            .padding(.horizontal, RPTheme.Spacing.md)
        }
    }

    private var batchPayoutButton: some View {
        Button {
            showBatchSheet = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 14, weight: .semibold))
                Text("Déclencher les virements du soir")
            }
        }
        .buttonStyle(RPPrimaryButtonStyle())
        .padding(.horizontal, RPTheme.Spacing.md)
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.6), trigger: showBatchSheet)
    }
}

struct AdminStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var isHighlighted: Bool = false
    var badgeCount: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isHighlighted ? RPTheme.accent : color)

                Spacer()

                if let count = badgeCount, count > 0 {
                    Text("\(count)")
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.red)
                        .clipShape(Capsule())
                }
            }

            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(isHighlighted ? RPTheme.accent : RPTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(.system(.caption, design: .default))
                .foregroundStyle(RPTheme.textSecondary)
        }
        .padding(RPTheme.Spacing.md)
        .background(
            isHighlighted
                ? AnyShapeStyle(LinearGradient(colors: [RPTheme.accent.opacity(0.08), RPTheme.accent.opacity(0.02)], startPoint: .topLeading, endPoint: .bottomTrailing))
                : AnyShapeStyle(Color(.secondarySystemBackground))
        )
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
    }
}
