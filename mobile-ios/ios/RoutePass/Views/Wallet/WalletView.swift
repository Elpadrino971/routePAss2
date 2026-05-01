import SwiftUI

struct WalletView: View {
    @State private var appeared: Bool = false
    @State private var showWithdrawSheet: Bool = false
    @State private var balanceAnimated: Bool = false
    @State private var selectedTransaction: WalletTransaction?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RPTheme.Spacing.lg) {
                    balanceCard
                    revenueChart
                    transactionsList
                    commissionNote
                }
                .padding(.bottom, RPTheme.Spacing.xxl)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Portefeuille")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showWithdrawSheet) {
                WithdrawSheet()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    appeared = true
                }
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
                    balanceAnimated = true
                }
            }
        }
    }

    private var balanceCard: some View {
        VStack(spacing: RPTheme.Spacing.lg) {
            VStack(spacing: RPTheme.Spacing.sm) {
                Text("Solde disponible")
                    .font(.system(.subheadline, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)

                Text(WalletMockData.availableBalance)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(RPTheme.textPrimary)
                    .scaleEffect(balanceAnimated ? 1 : 0.8)
                    .opacity(balanceAnimated ? 1 : 0)
            }

            HStack(spacing: RPTheme.Spacing.sm) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(RPTheme.textSecondary.opacity(0.6))
                Text("En attente : \(WalletMockData.pendingBalance)")
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color(.tertiarySystemFill))
            .clipShape(Capsule())

            Button {
                showWithdrawSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.down.to.line")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Retirer les fonds")
                }
            }
            .buttonStyle(RPPrimaryButtonStyle())
            .padding(.horizontal, RPTheme.Spacing.lg)
        }
        .padding(.vertical, RPTheme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [RPTheme.accent.opacity(0.06), RPTheme.accent.opacity(0.02)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        .padding(.horizontal, RPTheme.Spacing.md)
        .padding(.top, RPTheme.Spacing.sm)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    private var revenueChart: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: RPTheme.Spacing.xs) {
                    Text("Revenus 30 jours")
                        .font(.system(.headline, design: .default, weight: .bold))
                        .foregroundStyle(RPTheme.textPrimary)

                    Text(WalletMockData.monthlyRevenue)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(RPTheme.accent)
                }
                Spacer()
            }

            RevenueChartView(data: WalletMockData.revenuePoints)
                .frame(height: 140)
        }
        .padding(RPTheme.Spacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        .padding(.horizontal, RPTheme.Spacing.md)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
    }

    private var transactionsList: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            HStack {
                Text("Transactions récentes")
                    .font(.system(.headline, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)
                Spacer()
            }
            .padding(.horizontal, RPTheme.Spacing.md)

            VStack(spacing: 1) {
                ForEach(WalletMockData.transactions) { transaction in
                    TransactionRow(transaction: transaction)
                        .contextMenu {
                            Button {
                            } label: {
                                Label("Voir détail", systemImage: "doc.text.magnifyingglass")
                            }
                            Button {
                            } label: {
                                Label("Copier référence", systemImage: "doc.on.doc")
                            }
                            Divider()
                            Button(role: .destructive) {
                            } label: {
                                Label("Signaler", systemImage: "exclamationmark.triangle")
                            }
                        }
                }
            }
            .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
            .padding(.horizontal, RPTheme.Spacing.md)
        }
    }

    private var commissionNote: some View {
        HStack(spacing: RPTheme.Spacing.sm) {
            Image(systemName: "info.circle")
                .font(.system(size: 14))
                .foregroundStyle(RPTheme.textSecondary.opacity(0.6))

            Text("5% de commission ROUTEPASS déduits automatiquement")
                .font(.system(.caption, design: .default))
                .foregroundStyle(RPTheme.textSecondary)
        }
        .padding(.horizontal, RPTheme.Spacing.md)
    }
}
