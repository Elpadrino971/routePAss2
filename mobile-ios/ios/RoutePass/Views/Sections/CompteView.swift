import SwiftUI

/// Compte ROUTEPASS — profil avec avatar or, stats, wallet, options de menu,
/// préférences, sign out. Tout en dark luxury.
struct CompteView: View {
    @Environment(AppState.self) private var appState
    @State private var showWallet: Bool = false
    @State private var showAdmin: Bool = false
    @State private var appeared: Bool = false

    private var isAdmin: Bool { appState.selectedRole == .admin }

    private var firstName: String {
        appState.userEmail.split(separator: "@").first.map(String.init)?.capitalized ?? "Richard"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    profileHeader
                    walletPreview
                    if isAdmin { adminAccessCard }
                    accountOptions
                    settingsSection
                    logoutButton
                }
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
            .background(RPTheme.black.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
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
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var profileHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(RPTheme.goldGradient)
                    .frame(width: 88, height: 88)

                Text(initials())
                    .font(RPFont.display(28))
                    .foregroundStyle(RPTheme.black)
            }
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(RPTheme.gold)
                    .background(
                        Circle().fill(RPTheme.black).frame(width: 26, height: 26)
                    )
            }
            .shadow(color: RPTheme.gold.opacity(0.35), radius: 16, y: 6)

            VStack(spacing: 4) {
                Text(firstName)
                    .font(RPFont.display(22))
                    .foregroundStyle(RPTheme.white)

                Text(isAdmin ? "Administrateur ROUTEPASS" : "Membre Premium · 2024")
                    .font(RPFont.body(12))
                    .foregroundStyle(RPTheme.gray)
            }

            HStack(spacing: 0) {
                ProfileStat(value: "47",  label: "Trajets")
                divider
                ProfileStat(value: "12",  label: "Locations")
                divider
                ProfileStat(value: "4.9", label: "Avis")
            }
            .padding(.vertical, 14)
            .background(RPTheme.dark)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(RPTheme.border, lineWidth: 1)
            )
            .clipShape(.rect(cornerRadius: 16))
            .padding(.horizontal, RPTheme.Spacing.lg)
        }
        .padding(.top, 28)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
    }

    private var divider: some View {
        Rectangle().fill(RPTheme.border).frame(width: 1, height: 30)
    }

    private func initials() -> String {
        let parts = firstName.split(separator: " ").prefix(2)
        return parts.compactMap { $0.first.map(String.init) }.joined().uppercased()
    }

    // MARK: - Wallet card

    private var walletPreview: some View {
        Button {
            showWallet = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(RPTheme.goldGradient.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: "wallet.pass.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(RPTheme.gold)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Portefeuille")
                        .font(RPFont.body(14, weight: .semibold))
                        .foregroundStyle(RPTheme.white)
                    Text(WalletMockData.availableBalance)
                        .font(RPFont.mono(13, weight: .semibold))
                        .foregroundStyle(RPTheme.gold)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(RPTheme.gray)
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [RPTheme.gold.opacity(0.08), RPTheme.dark],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: RPTheme.cardRadius)
                    .stroke(RPTheme.gold.opacity(0.3), lineWidth: 1)
            )
            .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, RPTheme.Spacing.lg)
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.4), trigger: showWallet)
    }

    // MARK: - Admin card

    private var adminAccessCard: some View {
        Button {
            showAdmin = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(RPTheme.danger.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(RPTheme.danger)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Administration")
                        .font(RPFont.body(14, weight: .semibold))
                        .foregroundStyle(RPTheme.white)
                    Text("\(AdminMockData.dailyStats.pendingValidations) validations en attente")
                        .font(RPFont.body(12))
                        .foregroundStyle(RPTheme.gray)
                }

                Spacer()

                Text("\(AdminMockData.dailyStats.pendingValidations)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(RPTheme.danger))
            }
            .padding(14)
            .background(RPTheme.dark)
            .overlay(
                RoundedRectangle(cornerRadius: RPTheme.cardRadius)
                    .stroke(RPTheme.border, lineWidth: 1)
            )
            .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, RPTheme.Spacing.lg)
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.4), trigger: showAdmin)
    }

    // MARK: - Account options

    private var accountOptions: some View {
        VStack(spacing: 1) {
            ForEach(MockData.accountOptions) { option in
                Button { } label: {
                    HStack(spacing: 14) {
                        Image(systemName: option.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(RPTheme.gold)
                            .frame(width: 28, height: 28)
                        Text(option.title)
                            .font(RPFont.body(14, weight: .medium))
                            .foregroundStyle(RPTheme.white)
                        Spacer()
                        if let count = option.count {
                            Text("\(count)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(RPTheme.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(RPTheme.gold))
                        }
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(RPTheme.gray)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background(RPTheme.dark)
                }
                .buttonStyle(.plain)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: RPTheme.cardRadius)
                .stroke(RPTheme.border, lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        .padding(.horizontal, RPTheme.Spacing.lg)
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PRÉFÉRENCES").rpKicker()
                .padding(.horizontal, RPTheme.Spacing.lg)

            VStack(spacing: 1) {
                SettingsRow(icon: "faceid",          title: "Face ID",       hasToggle: true)
                SettingsRow(icon: "moon.fill",       title: "Mode sombre",   hasToggle: true)
                SettingsRow(icon: "bell.badge.fill", title: "Notifications", hasToggle: true)
                SettingsRow(icon: "globe",           title: "Langue", value: "Français")
            }
            .overlay(
                RoundedRectangle(cornerRadius: RPTheme.cardRadius)
                    .stroke(RPTheme.border, lineWidth: 1)
            )
            .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
            .padding(.horizontal, RPTheme.Spacing.lg)
        }
    }

    // MARK: - Logout

    private var logoutButton: some View {
        Button("Se déconnecter") {
            appState.signOut()
        }
        .buttonStyle(RPSecondaryButtonStyle())
        .padding(.horizontal, RPTheme.Spacing.lg)
        .padding(.top, 4)
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.5), trigger: appState.isAuthenticated)
    }
}

struct ProfileStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(RPFont.mono(18, weight: .semibold))
                .foregroundStyle(RPTheme.white)
            Text(label)
                .font(RPFont.body(10))
                .foregroundStyle(RPTheme.gray)
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
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(RPTheme.gold)
                .frame(width: 28, height: 28)

            Text(title)
                .font(RPFont.body(14, weight: .medium))
                .foregroundStyle(RPTheme.white)

            Spacer()

            if hasToggle {
                Toggle("", isOn: $isOn)
                    .tint(RPTheme.gold)
                    .labelsHidden()
            } else if let value {
                Text(value)
                    .font(RPFont.body(13))
                    .foregroundStyle(RPTheme.gray)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(RPTheme.dark)
    }
}
