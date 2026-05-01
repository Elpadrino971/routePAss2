import SwiftUI

struct CompteView: View {
    @Environment(AppState.self) private var appState
    @State private var showWallet: Bool = false
    @State private var showAdmin: Bool = false
    @State private var appeared: Bool = false

    private var isAdmin: Bool {
        appState.selectedRole == .admin
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RPTheme.Spacing.lg) {
                    profileHeader
                    walletPreview
                    if isAdmin {
                        adminAccessCard
                    }
                    accountOptions
                    settingsSection
                    logoutButton
                }
                .padding(.bottom, 80)
            }
            .scrollIndicators(.hidden)
            .navigationDestination(isPresented: $showWallet) {
                WalletView()
            }
            .navigationDestination(isPresented: $showAdmin) {
                AdminDashboardView()
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    appeared = true
                }
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: RPTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [RPTheme.accent, RPTheme.accent.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)

                Text("AK")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
            }
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(RPTheme.accent)
                    .background(
                        Circle()
                            .fill(Color(.systemBackground))
                            .frame(width: 26, height: 26)
                    )
            }

            VStack(spacing: RPTheme.Spacing.xs) {
                Text("Alexandre Karim")
                    .font(.system(.title3, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Text(isAdmin ? "Administrateur ROUTEPASS" : "Membre Premium depuis 2024")
                    .font(.system(.subheadline, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }

            HStack(spacing: 0) {
                ProfileStat(value: "47", label: "Trajets")
                Divider().frame(height: 32)
                ProfileStat(value: "12", label: "Locations")
                Divider().frame(height: 32)
                ProfileStat(value: "4.9", label: "Avis")
            }
            .padding(.vertical, 14)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 16))
            .padding(.horizontal, RPTheme.Spacing.md)
        }
        .padding(.top, RPTheme.Spacing.xl)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private var walletPreview: some View {
        Button {
            showWallet = true
        } label: {
            HStack(spacing: 14) {
                Circle()
                    .fill(RPTheme.accent.opacity(0.12))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: "wallet.pass.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(RPTheme.accent)
                    }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Portefeuille")
                        .font(.system(.headline, design: .default, weight: .bold))
                        .foregroundStyle(RPTheme.textPrimary)

                    Text(WalletMockData.availableBalance)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(RPTheme.accent)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(RPTheme.textSecondary.opacity(0.5))
            }
            .padding(RPTheme.Spacing.md)
            .background(
                LinearGradient(
                    colors: [RPTheme.accent.opacity(0.06), RPTheme.accent.opacity(0.02)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.4), trigger: showWallet)
    }

    private var adminAccessCard: some View {
        Button {
            showAdmin = true
        } label: {
            HStack(spacing: 14) {
                Circle()
                    .fill(.red.opacity(0.12))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 20))
                            .foregroundStyle(.red)
                    }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Administration")
                        .font(.system(.headline, design: .default, weight: .bold))
                        .foregroundStyle(RPTheme.textPrimary)

                    Text("\(AdminMockData.dailyStats.pendingValidations) validations en attente")
                        .font(.system(.subheadline, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                }

                Spacer()

                Text("\(AdminMockData.dailyStats.pendingValidations)")
                    .font(.system(.footnote, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.red)
                    .clipShape(Capsule())
            }
            .padding(RPTheme.Spacing.md)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.4), trigger: showAdmin)
    }

    private var accountOptions: some View {
        VStack(spacing: 1) {
            ForEach(MockData.accountOptions) { option in
                Button {
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: option.icon)
                            .font(.system(size: 18))
                            .foregroundStyle(RPTheme.accent)
                            .frame(width: 32, height: 32)

                        Text(option.title)
                            .font(.system(.body, design: .default, weight: .medium))
                            .foregroundStyle(RPTheme.textPrimary)

                        Spacer()

                        if let count = option.count {
                            Text("\(count)")
                                .font(.system(.footnote, design: .rounded, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(RPTheme.accent)
                                .clipShape(Capsule())
                        }

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(RPTheme.textSecondary.opacity(0.5))
                    }
                    .padding(.horizontal, RPTheme.Spacing.md)
                    .padding(.vertical, 14)
                    .background(Color(.secondarySystemBackground))
                }
            }
        }
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.sm) {
            Text("Préférences")
                .font(.system(.footnote, design: .default, weight: .semibold))
                .foregroundStyle(RPTheme.textSecondary)
                .padding(.horizontal, RPTheme.Spacing.md)

            VStack(spacing: 1) {
                SettingsRow(icon: "faceid", title: "Face ID", hasToggle: true)
                SettingsRow(icon: "moon.fill", title: "Mode sombre", hasToggle: true)
                SettingsRow(icon: "bell.badge.fill", title: "Notifications", hasToggle: true)
                SettingsRow(icon: "globe", title: "Langue", value: "Français")
            }
            .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
            .padding(.horizontal, RPTheme.Spacing.md)
        }
    }

    private var logoutButton: some View {
        Button("Se déconnecter") {
            appState.signOut()
        }
        .buttonStyle(RPSecondaryButtonStyle())
        .padding(.horizontal, RPTheme.Spacing.md)
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.5), trigger: appState.isAuthenticated)
    }
}

struct ProfileStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)
            Text(label)
                .font(.system(.caption2, design: .default))
                .foregroundStyle(RPTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var hasToggle: Bool = false
    var value: String? = nil
    @State private var isOn: Bool = true

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(RPTheme.accent)
                .frame(width: 32, height: 32)

            Text(title)
                .font(.system(.body, design: .default, weight: .medium))
                .foregroundStyle(RPTheme.textPrimary)

            Spacer()

            if hasToggle {
                Toggle("", isOn: $isOn)
                    .tint(RPTheme.accent)
                    .labelsHidden()
            } else if let value {
                Text(value)
                    .font(.system(.subheadline, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
    }
}
