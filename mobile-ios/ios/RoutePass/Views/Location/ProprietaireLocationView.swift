import SwiftUI

struct ProprietaireLocationView: View {
    @State private var viewModel = LocationViewModel()
    @State private var showSettings: Bool = false

    private let property: RentalItem = LocationMockData.rentalItems[3]

    @State private var showSmartAccess: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: RPTheme.Spacing.lg) {
                statusSection
                smartAccessBanner
                revenueSection
                weekPlanningSection
                tenantHistorySection
                settingsButton
            }
            .padding(.bottom, 80)
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showSettings) {
            PropertySettingsSheet(
                item: property,
                cleaningMinutes: $viewModel.ownerCleaningMinutes
            )
        }
        .sheet(isPresented: $showSmartAccess) {
            NavigationStack {
                ScrollView {
                    SmartAccessOwnerView()
                        .padding(.top, RPTheme.Spacing.md)
                        .padding(.bottom, RPTheme.Spacing.xxl)
                }
                .scrollIndicators(.hidden)
                .navigationTitle("Accès intelligent")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Fermer") { showSmartAccess = false }
                    }
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    private var smartAccessBanner: some View {
        Button {
            showSmartAccess = true
        } label: {
            HStack(spacing: RPTheme.Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color(white: 0.15), Color(white: 0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(RPTheme.accent.opacity(0.3), lineWidth: 1)
                        }

                    Image(systemName: "wave.3.right")
                        .font(.system(size: 18))
                        .foregroundStyle(RPTheme.accent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Accès intelligent")
                        .font(.system(.subheadline, design: .default, weight: .semibold))
                        .foregroundStyle(RPTheme.textPrimary)

                    Text("Cartes NFC · Serrures · Électricité")
                        .font(.system(.caption2, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Circle()
                        .fill(.green)
                        .frame(width: 6, height: 6)
                    Text("1 active")
                        .font(.system(.caption2, design: .rounded, weight: .semibold))
                        .foregroundStyle(.green)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(RPTheme.textSecondary.opacity(0.5))
            }
            .padding(RPTheme.Spacing.md)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private var statusSection: some View {
        VStack(spacing: RPTheme.Spacing.md) {
            Text("Statut actuel")
                .font(.system(.caption, design: .default, weight: .semibold))
                .foregroundStyle(RPTheme.textSecondary)
                .textCase(.uppercase)

            VStack(spacing: RPTheme.Spacing.md) {
                RPBadge(status: viewModel.ownerPropertyStatus)
                    .scaleEffect(1.3)

                Text(property.name)
                    .font(.system(.title3, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                if viewModel.ownerPropertyStatus == .nettoyage {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Text("Disponible dans ~\(viewModel.ownerCleaningMinutes) min")
                            .font(.system(.caption, design: .default))
                            .foregroundStyle(RPTheme.textSecondary)
                    }
                }
            }
            .padding(RPTheme.Spacing.xl)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
            .shadow(color: RPTheme.cardShadow, radius: RPTheme.cardShadowRadius, x: 0, y: RPTheme.cardShadowY)
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .padding(.top, RPTheme.Spacing.lg)
    }

    private var revenueSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Revenus")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)
                .padding(.horizontal, RPTheme.Spacing.md)

            HStack(spacing: RPTheme.Spacing.sm) {
                revenueCard(label: "Aujourd'hui", amount: viewModel.ownerTodayRevenue, icon: "sun.max.fill")
                revenueCard(label: "Semaine", amount: viewModel.ownerWeekRevenue, icon: "calendar")
                revenueCard(label: "Mois", amount: viewModel.ownerMonthRevenue, icon: "chart.bar.fill")
            }
            .padding(.horizontal, RPTheme.Spacing.md)
        }
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

    private var weekPlanningSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Planning semaine")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)
                .padding(.horizontal, RPTheme.Spacing.md)

            VStack(spacing: RPTheme.Spacing.sm) {
                ForEach(viewModel.weekEvents) { event in
                    WeekEventRow(event: event)
                }
            }
            .padding(.horizontal, RPTheme.Spacing.md)
        }
    }

    private var tenantHistorySection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Historique locataires")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)
                .padding(.horizontal, RPTheme.Spacing.md)

            VStack(spacing: RPTheme.Spacing.sm) {
                ForEach(viewModel.tenantHistory) { record in
                    TenantRow(record: record)
                }
            }
            .padding(.horizontal, RPTheme.Spacing.md)
        }
    }

    private var settingsButton: some View {
        Button {
            showSettings = true
        } label: {
            HStack(spacing: RPTheme.Spacing.sm) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16))
                Text("Paramètres du bien")
                    .font(.system(.body, design: .rounded, weight: .semibold))
            }
        }
        .buttonStyle(RPSecondaryButtonStyle())
        .padding(.horizontal, RPTheme.Spacing.md)
    }
}

struct WeekEventRow: View {
    let event: WeekEvent
    @State private var appeared: Bool = false

    var body: some View {
        HStack(spacing: RPTheme.Spacing.md) {
            Text(event.day)
                .font(.system(.caption, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textSecondary)
                .frame(width: 32)

            RoundedRectangle(cornerRadius: 2)
                .fill(event.color)
                .frame(width: 3, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(.subheadline, design: .default, weight: .medium))
                    .foregroundStyle(RPTheme.textPrimary)

                Text(event.timeRange)
                    .font(.system(.caption2, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, RPTheme.Spacing.sm)
        .padding(.horizontal, RPTheme.Spacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 12))
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -12)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
}

struct TenantRow: View {
    let record: TenantRecord
    @State private var appeared: Bool = false

    var body: some View {
        HStack(spacing: RPTheme.Spacing.md) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(RPTheme.accent.opacity(0.5))

            VStack(alignment: .leading, spacing: 2) {
                Text(record.tenantName)
                    .font(.system(.subheadline, design: .default, weight: .medium))
                    .foregroundStyle(RPTheme.textPrimary)

                Text(record.dates)
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(record.amount)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(RPTheme.accent)

                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.orange)
                    Text(String(format: "%.1f", record.rating))
                        .font(.system(.caption2, design: .default, weight: .semibold))
                }
            }
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
