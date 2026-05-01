import SwiftUI
import Combine

struct SmartAccessCardView: View {
    let booking: RentalBooking
    let onEndRental: () -> Void
    let onDismiss: () -> Void

    @State private var accessCard: SmartAccessCard?
    @State private var timeRemaining: TimeInterval = 0
    @State private var cardAppeared: Bool = false
    @State private var devicesAppeared: Bool = false
    @State private var cardPulse: Bool = false
    @State private var showEndConfirmation: Bool = false
    @State private var showDeactivationFlow: Bool = false
    @State private var deactivationProgress: Double = 0
    @State private var hapticTrigger: Int = 0
    @State private var successHaptic: Int = 0

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    nfcCardSection
                        .padding(.top, RPTheme.Spacing.md)

                    deviceControlsSection
                        .padding(.top, RPTheme.Spacing.xl)

                    timerSection
                        .padding(.top, RPTheme.Spacing.xl)

                    accessLogSection
                        .padding(.top, RPTheme.Spacing.xl)

                    actionsSection
                        .padding(.top, RPTheme.Spacing.xl)
                }
                .padding(.bottom, RPTheme.Spacing.xxl)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Carte d'accès")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(RPTheme.textSecondary)
                            .frame(width: 30, height: 30)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
            .alert("Terminer la location ?", isPresented: $showEndConfirmation) {
                Button("Annuler", role: .cancel) {}
                Button("Désactiver et terminer", role: .destructive) {
                    startDeactivation()
                }
            } message: {
                Text("La carte sera désactivée, la serrure verrouillée et l'électricité coupée automatiquement.")
            }
            .fullScreenCover(isPresented: $showDeactivationFlow) {
                DeactivationFlowView(
                    propertyName: booking.item.name,
                    progress: deactivationProgress,
                    onComplete: {
                        showDeactivationFlow = false
                        onEndRental()
                    }
                )
            }
            .onReceive(timer) { _ in
                timeRemaining = max(0, booking.endDate.timeIntervalSince(Date()))
                if timeRemaining <= 0, let card = accessCard, card.state == .active {
                    withAnimation(.spring(response: 0.5)) {
                        accessCard?.state = .expired
                    }
                }
            }
            .sensoryFeedback(.impact(flexibility: .soft), trigger: hapticTrigger)
            .sensoryFeedback(.success, trigger: successHaptic)
            .onAppear {
                let card = SmartAccessMockData.createCard(for: booking)
                accessCard = card
                timeRemaining = max(0, booking.endDate.timeIntervalSince(Date()))

                withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1)) {
                    cardAppeared = true
                }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4)) {
                    devicesAppeared = true
                }
                successHaptic += 1
            }
        }
    }

    private var nfcCardSection: some View {
        VStack(spacing: RPTheme.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.15, green: 0.15, blue: 0.17),
                                Color(red: 0.08, green: 0.08, blue: 0.10)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 220)
                    .overlay {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        RPTheme.accent.opacity(cardPulse ? 0.6 : 0.2),
                                        RPTheme.accent.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    }
                    .shadow(color: RPTheme.accent.opacity(cardPulse ? 0.2 : 0.05), radius: 20, x: 0, y: 8)
                    .onAppear { cardPulse = true }
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: cardPulse)

                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(systemName: "wave.3.right")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(RPTheme.accent)

                        Spacer()

                        cardStateBadge
                    }

                    Spacer()

                    HStack(spacing: 6) {
                        Image(systemName: "contactless.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(RPTheme.accent.opacity(0.7))
                        Text(accessCard?.cardNumber ?? "•••• •••• •••• ••••")
                            .font(.system(size: 18, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.9))
                    }

                    Spacer().frame(height: 16)

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("BIEN")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.4))
                            Text(booking.item.name)
                                .font(.system(.subheadline, design: .default, weight: .semibold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("EXPIRE")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.4))
                            Text(formatShortDate(booking.endDate))
                                .font(.system(.subheadline, design: .default, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }

                    Spacer().frame(height: 12)

                    HStack {
                        Text("ROUTEPASS")
                            .font(.system(size: 11, weight: .bold, design: .default))
                            .foregroundStyle(RPTheme.accent)
                            .tracking(3)

                        Spacer()

                        Image(systemName: booking.item.icon)
                            .font(.system(size: 18))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }
                .padding(RPTheme.Spacing.lg)
            }
            .scaleEffect(cardAppeared ? 1 : 0.92)
            .opacity(cardAppeared ? 1 : 0)
        }
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private var cardStateBadge: some View {
        HStack(spacing: 5) {
            let state = accessCard?.state ?? .inactive
            Circle()
                .fill(state.color)
                .frame(width: 7, height: 7)
                .shadow(color: state.color.opacity(0.6), radius: 4)

            Text(state.rawValue)
                .font(.system(.caption2, design: .rounded, weight: .bold))
                .foregroundStyle(state.color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill((accessCard?.state ?? .inactive).color.opacity(0.15))
        )
    }

    private var deviceControlsSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            HStack {
                Text("Appareils connectés")
                    .font(.system(.headline, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Spacer()

                let activeCount = accessCard?.devices.filter(\.isActive).count ?? 0
                let total = accessCard?.devices.count ?? 0
                Text("\(activeCount)/\(total) actifs")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(RPTheme.accent)
            }
            .padding(.horizontal, RPTheme.Spacing.md)

            VStack(spacing: RPTheme.Spacing.sm) {
                ForEach(Array((accessCard?.devices ?? []).enumerated()), id: \.element.id) { index, device in
                    DeviceControlRow(device: device)
                        .opacity(devicesAppeared ? 1 : 0)
                        .offset(y: devicesAppeared ? 0 : 12)
                        .animation(
                            .spring(response: 0.45, dampingFraction: 0.8).delay(Double(index) * 0.08),
                            value: devicesAppeared
                        )
                }
            }
            .padding(.horizontal, RPTheme.Spacing.md)
        }
    }

    private var timerSection: some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            Text("TEMPS RESTANT")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(RPTheme.textSecondary)
                .tracking(2)

            Text(formatTime(timeRemaining))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(timeRemaining < 3600 ? .red : RPTheme.textPrimary)
                .monospacedDigit()
                .contentTransition(.numericText())

            HStack(spacing: RPTheme.Spacing.sm) {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundStyle(RPTheme.textSecondary)
                Text("\(formatFullDate(booking.startDate)) → \(formatFullDate(booking.endDate))")
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }

            if timeRemaining < 3600 && timeRemaining > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                    Text("La carte sera désactivée automatiquement à expiration")
                        .font(.system(.caption2, design: .default))
                }
                .foregroundStyle(.red)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.red.opacity(0.08))
                .clipShape(Capsule())
                .padding(.top, RPTheme.Spacing.xs)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, RPTheme.Spacing.lg)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private var accessLogSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            HStack {
                Text("Journal d'accès")
                    .font(.system(.headline, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Spacer()

                Image(systemName: "clock.arrow.circlepath")
                    .font(.caption)
                    .foregroundStyle(RPTheme.textSecondary)
            }
            .padding(.horizontal, RPTheme.Spacing.md)

            VStack(spacing: 0) {
                ForEach(accessCard?.accessLog ?? []) { entry in
                    AccessLogRow(entry: entry)

                    if entry.id != accessCard?.accessLog.last?.id {
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

    private var actionsSection: some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            Button {
                hapticTrigger += 1
                showEndConfirmation = true
            } label: {
                HStack(spacing: RPTheme.Spacing.sm) {
                    Image(systemName: "power")
                        .font(.system(size: 16, weight: .bold))
                    Text("Terminer et désactiver")
                        .font(.system(.body, design: .rounded, weight: .semibold))
                }
            }
            .buttonStyle(RPPrimaryButtonStyle())

            Button {} label: {
                HStack(spacing: RPTheme.Spacing.sm) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                    Text("Signaler un problème")
                        .font(.system(.subheadline, design: .default, weight: .medium))
                }
            }
            .buttonStyle(RPSecondaryButtonStyle())
        }
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private func startDeactivation() {
        showDeactivationFlow = true
        deactivationProgress = 0

        Task {
            for step in 1...4 {
                try? await Task.sleep(for: .seconds(0.8))
                withAnimation(.spring(response: 0.4)) {
                    deactivationProgress = Double(step) / 4.0
                }
            }
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "d MMM HH:mm"
        return formatter.string(from: date)
    }

    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "d MMM à HH:mm"
        return formatter.string(from: date)
    }
}

struct DeviceControlRow: View {
    let device: SmartDevice

    @State private var isToggling: Bool = false

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

                Text(device.type.rawValue)
                    .font(.system(.caption2, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }

            Spacer()

            if isToggling {
                ProgressView()
                    .controlSize(.small)
            } else {
                HStack(spacing: 5) {
                    Circle()
                        .fill(device.isActive ? .green : .red)
                        .frame(width: 6, height: 6)
                    Text(device.isActive ? "ON" : "OFF")
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(device.isActive ? .green : .red)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background((device.isActive ? Color.green : Color.red).opacity(0.1))
                .clipShape(Capsule())
            }
        }
        .padding(RPTheme.Spacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 14))
    }
}

struct AccessLogRow: View {
    let entry: AccessLogEntry

    var body: some View {
        HStack(spacing: RPTheme.Spacing.md) {
            Image(systemName: entry.icon)
                .font(.system(size: 14))
                .foregroundStyle(entry.color)
                .frame(width: 32, height: 32)
                .background(entry.color.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.event)
                    .font(.system(.subheadline, design: .default, weight: .medium))
                    .foregroundStyle(RPTheme.textPrimary)

                Text(formatLogTime(entry.timestamp))
                    .font(.system(.caption2, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }

            Spacer()
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .padding(.vertical, 10)
    }

    private func formatLogTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

struct DeactivationFlowView: View {
    let propertyName: String
    let progress: Double
    let onComplete: () -> Void

    @State private var appeared: Bool = false
    @State private var completedHaptic: Int = 0

    private let steps: [(icon: String, label: String, detail: String)] = [
        ("creditcard.fill", "Carte NFC", "Désactivation..."),
        ("lock.fill", "Serrure", "Verrouillage..."),
        ("bolt.slash.fill", "Électricité", "Coupure..."),
        ("sparkles", "Nettoyage", "Statut mis à jour"),
    ]

    var body: some View {
        VStack(spacing: RPTheme.Spacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color(.tertiarySystemFill), lineWidth: 6)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        progress >= 1 ? Color.green : RPTheme.accent,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                if progress >= 1 {
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.green)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Image(systemName: "power")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(RPTheme.accent)
                }
            }

            VStack(spacing: RPTheme.Spacing.sm) {
                Text(progress >= 1 ? "Location terminée" : "Désactivation en cours")
                    .font(.system(.title2, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Text(propertyName)
                    .font(.system(.subheadline, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }

            VStack(spacing: RPTheme.Spacing.md) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    let stepProgress = Double(index + 1) / Double(steps.count)
                    let isComplete = progress >= stepProgress
                    let isActive = progress >= stepProgress - 0.25 && !isComplete

                    HStack(spacing: RPTheme.Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(isComplete ? deactivationStepColor(index) : Color(.tertiarySystemFill))
                                .frame(width: 36, height: 36)

                            if isActive {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: isComplete ? "checkmark" : step.icon)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(isComplete ? .white : RPTheme.textSecondary)
                            }
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text(step.label)
                                .font(.system(.subheadline, design: .default, weight: .medium))
                                .foregroundStyle(RPTheme.textPrimary)

                            Text(isComplete ? "Terminé" : (isActive ? step.detail : "En attente"))
                                .font(.system(.caption2, design: .default))
                                .foregroundStyle(isComplete ? .green : RPTheme.textSecondary)
                        }

                        Spacer()

                        if isComplete {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(.vertical, RPTheme.Spacing.sm)
                    .padding(.horizontal, RPTheme.Spacing.md)
                }
            }
            .padding(RPTheme.Spacing.md)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
            .padding(.horizontal, RPTheme.Spacing.md)

            Spacer()

            if progress >= 1 {
                Button {
                    onComplete()
                } label: {
                    Text("Terminé")
                        .font(.system(.body, design: .rounded, weight: .bold))
                }
                .buttonStyle(RPPrimaryButtonStyle())
                .padding(.horizontal, RPTheme.Spacing.md)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.vertical, RPTheme.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RPTheme.backgroundPrimary)
        .sensoryFeedback(.success, trigger: completedHaptic)
        .onChange(of: progress) { _, newValue in
            if newValue >= 1 {
                completedHaptic += 1
            }
        }
    }
}

private func deactivationStepColor(_ index: Int) -> Color {
    switch index {
    case 0: .red
    case 1: .red
    case 2: .orange
    case 3: .green
    default: .green
    }
}
