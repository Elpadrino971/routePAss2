import SwiftUI

struct SmartAccessOwnerView: View {
    @State private var devices: [SmartDevice] = SmartAccessMockData.devicesForCategory(.appartements)
    @State private var accessLog: [AccessLogEntry] = SmartAccessMockData.ownerAccessLog()
    @State private var activeCards: Int = 1
    @State private var totalAccesses: Int = 47
    @State private var showRevokeConfirmation: Bool = false
    @State private var showEmergencySheet: Bool = false
    @State private var hapticTrigger: Int = 0
    @State private var appeared: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.lg) {
            headerStats
            activeCardsSection
            deviceMasterControls
            recentAccessLog
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                appeared = true
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: hapticTrigger)
        .alert("Couper tous les accès ?", isPresented: $showRevokeConfirmation) {
            Button("Annuler", role: .cancel) {}
            Button("Tout couper", role: .destructive) {
                withAnimation(.spring(response: 0.4)) {
                    for i in devices.indices {
                        devices[i].isActive = false
                    }
                    activeCards = 0
                }
            }
        } message: {
            Text("Toutes les cartes seront désactivées, les serrures verrouillées et l'électricité coupée immédiatement.")
        }
        .sheet(isPresented: $showEmergencySheet) {
            EmergencyControlSheet(
                devices: $devices,
                onDismiss: { showEmergencySheet = false }
            )
        }
    }

    private var headerStats: some View {
        HStack(spacing: RPTheme.Spacing.sm) {
            statCard(
                value: "\(activeCards)",
                label: "Cartes actives",
                icon: "creditcard.fill",
                color: activeCards > 0 ? .green : .gray
            )
            statCard(
                value: "\(totalAccesses)",
                label: "Accès ce mois",
                icon: "door.left.hand.open",
                color: .blue
            )
            statCard(
                value: "\(devices.filter(\.isActive).count)",
                label: "Appareils ON",
                icon: "bolt.fill",
                color: .yellow
            )
        }
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)

            Text(value)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)

            Text(label)
                .font(.system(.caption2, design: .default))
                .foregroundStyle(RPTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, RPTheme.Spacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var activeCardsSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            HStack {
                Text("Cartes en cours")
                    .font(.system(.headline, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Spacer()

                if activeCards > 0 {
                    Button {
                        hapticTrigger += 1
                        showRevokeConfirmation = true
                    } label: {
                        Text("Tout révoquer")
                            .font(.system(.caption, design: .default, weight: .semibold))
                            .foregroundStyle(.red)
                    }
                }
            }
            .padding(.horizontal, RPTheme.Spacing.md)

            if activeCards > 0 {
                ActiveCardRow(
                    cardNumber: "4821",
                    tenantName: "Lucas Martin",
                    expiresIn: "2j 14h",
                    isActive: true
                )
                .padding(.horizontal, RPTheme.Spacing.md)
            } else {
                HStack(spacing: RPTheme.Spacing.sm) {
                    Image(systemName: "creditcard.trianglebadge.exclamationmark")
                        .font(.system(size: 16))
                        .foregroundStyle(RPTheme.textSecondary)
                    Text("Aucune carte active")
                        .font(.system(.subheadline, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, RPTheme.Spacing.lg)
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 14))
                .padding(.horizontal, RPTheme.Spacing.md)
            }
        }
    }

    private var deviceMasterControls: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            HStack {
                Text("Contrôle appareils")
                    .font(.system(.headline, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Spacer()

                Button {
                    hapticTrigger += 1
                    showEmergencySheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.shield.fill")
                            .font(.system(size: 11))
                        Text("Urgence")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                    }
                    .foregroundStyle(.red)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.red.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, RPTheme.Spacing.md)

            VStack(spacing: RPTheme.Spacing.sm) {
                ForEach(Array(devices.enumerated()), id: \.element.id) { index, device in
                    OwnerDeviceRow(device: device) {
                        withAnimation(.spring(response: 0.35)) {
                            devices[index].isActive.toggle()
                        }
                        hapticTrigger += 1
                    }
                }
            }
            .padding(.horizontal, RPTheme.Spacing.md)
        }
    }

    private var recentAccessLog: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            HStack {
                Text("Historique accès")
                    .font(.system(.headline, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Spacer()

                Text("Aujourd'hui")
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }
            .padding(.horizontal, RPTheme.Spacing.md)

            VStack(spacing: 0) {
                ForEach(accessLog.prefix(6)) { entry in
                    AccessLogRow(entry: entry)

                    if entry.id != accessLog.prefix(6).last?.id {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 16))
            .padding(.horizontal, RPTheme.Spacing.md)
        }
    }
}

struct ActiveCardRow: View {
    let cardNumber: String
    let tenantName: String
    let expiresIn: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: RPTheme.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [Color(white: 0.15), Color(white: 0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 32)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(RPTheme.accent.opacity(0.4), lineWidth: 1)
                    }

                Image(systemName: "wave.3.right")
                    .font(.system(size: 12))
                    .foregroundStyle(RPTheme.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(tenantName)
                        .font(.system(.subheadline, design: .default, weight: .semibold))
                        .foregroundStyle(RPTheme.textPrimary)

                    Circle()
                        .fill(.green)
                        .frame(width: 6, height: 6)
                }

                Text("Carte #\(cardNumber) · Expire dans \(expiresIn)")
                    .font(.system(.caption2, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(RPTheme.textSecondary.opacity(0.5))
        }
        .padding(RPTheme.Spacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 14))
    }
}

struct OwnerDeviceRow: View {
    let device: SmartDevice
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: RPTheme.Spacing.md) {
            Image(systemName: device.isActive ? device.type.activeIcon : device.type.icon)
                .font(.system(size: 20))
                .foregroundStyle(device.isActive ? RPTheme.accent : RPTheme.textSecondary)
                .frame(width: 40, height: 40)
                .background(device.isActive ? RPTheme.accent.opacity(0.12) : Color(.tertiarySystemFill))
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(device.name)
                    .font(.system(.subheadline, design: .default, weight: .medium))
                    .foregroundStyle(RPTheme.textPrimary)

                Text(device.isActive ? "Actif" : "Désactivé")
                    .font(.system(.caption2, design: .default))
                    .foregroundStyle(device.isActive ? .green : RPTheme.textSecondary)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { device.isActive },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
            .tint(RPTheme.accent)
        }
        .padding(RPTheme.Spacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 14))
    }
}

struct EmergencyControlSheet: View {
    @Binding var devices: [SmartDevice]
    let onDismiss: () -> Void

    @State private var isProcessing: Bool = false
    @State private var allCut: Bool = false
    @State private var hapticTrigger: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: RPTheme.Spacing.xl) {
                Spacer()

                Image(systemName: "exclamationmark.shield.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.red)
                    .padding(.bottom, RPTheme.Spacing.sm)

                VStack(spacing: RPTheme.Spacing.sm) {
                    Text("Contrôle d'urgence")
                        .font(.system(.title2, design: .default, weight: .bold))
                        .foregroundStyle(RPTheme.textPrimary)

                    Text("Coupez immédiatement tous les accès et appareils du bien. Les cartes actives seront révoquées.")
                        .font(.system(.subheadline, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, RPTheme.Spacing.lg)
                }

                if allCut {
                    VStack(spacing: RPTheme.Spacing.md) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.green)

                        Text("Tous les accès coupés")
                            .font(.system(.headline, design: .default, weight: .bold))
                            .foregroundStyle(.green)
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                Spacer()

                VStack(spacing: RPTheme.Spacing.sm) {
                    if !allCut {
                        Button {
                            hapticTrigger += 1
                            isProcessing = true
                            Task {
                                try? await Task.sleep(for: .seconds(1.5))
                                withAnimation(.spring(response: 0.5)) {
                                    for i in devices.indices {
                                        devices[i].isActive = false
                                    }
                                    allCut = true
                                    isProcessing = false
                                }
                            }
                        } label: {
                            HStack(spacing: RPTheme.Spacing.sm) {
                                if isProcessing {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "power")
                                        .font(.system(size: 16, weight: .bold))
                                    Text("Tout couper maintenant")
                                        .font(.system(.body, design: .rounded, weight: .bold))
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.red)
                            .clipShape(.rect(cornerRadius: RPTheme.buttonRadius))
                        }
                        .disabled(isProcessing)
                    }

                    Button {
                        onDismiss()
                    } label: {
                        Text(allCut ? "Fermer" : "Annuler")
                            .font(.system(.body, design: .default, weight: .medium))
                    }
                    .buttonStyle(RPGhostButtonStyle())
                }
                .padding(.horizontal, RPTheme.Spacing.md)
            }
            .padding(.vertical, RPTheme.Spacing.xl)
            .sensoryFeedback(.warning, trigger: hapticTrigger)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { onDismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
