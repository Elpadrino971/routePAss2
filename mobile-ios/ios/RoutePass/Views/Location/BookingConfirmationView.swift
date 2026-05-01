import SwiftUI

struct BookingConfirmationView: View {
    let booking: RentalBooking
    let onAccessView: () -> Void
    let onShowMap: () -> Void
    let onDismiss: () -> Void

    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var cardActivating: Bool = false
    @State private var cardActivated: Bool = false
    @State private var hapticTrigger: Int = 0
    @State private var activationHaptic: Int = 0

    var body: some View {
        VStack(spacing: RPTheme.Spacing.xl) {
            Spacer()

            if cardActivated {
                activatedCardVisual
                    .transition(.scale.combined(with: .opacity))
            } else if cardActivating {
                activatingVisual
                    .transition(.scale.combined(with: .opacity))
            } else {
                checkmarkCircle
            }

            VStack(spacing: RPTheme.Spacing.sm) {
                Text(cardActivated ? "Carte d'accès activée" : "Réservation confirmée")
                    .font(.system(.title2, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)
                    .contentTransition(.numericText())

                Text(booking.item.name)
                    .font(.system(.subheadline, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }
            .opacity(contentOpacity)

            bookingDetails
                .opacity(contentOpacity)

            if cardActivated {
                smartCardPreview
                    .opacity(contentOpacity)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                qrAccessCard
                    .opacity(contentOpacity)
            }

            Spacer()

            VStack(spacing: RPTheme.Spacing.sm) {
                Button {
                    if !cardActivated {
                        activateCard()
                    } else {
                        onAccessView()
                    }
                } label: {
                    HStack(spacing: RPTheme.Spacing.sm) {
                        if cardActivating {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: cardActivated ? "creditcard.fill" : "wave.3.right")
                                .font(.system(size: 16))
                            Text(cardActivated ? "Ouvrir ma carte d'accès" : "Activer la carte NFC")
                        }
                    }
                }
                .buttonStyle(RPPrimaryButtonStyle())
                .disabled(cardActivating)

                Button {
                    onShowMap()
                } label: {
                    HStack(spacing: RPTheme.Spacing.sm) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 14))
                        Text("Voir sur la carte")
                    }
                }
                .buttonStyle(RPSecondaryButtonStyle())

                Button {
                    onDismiss()
                } label: {
                    Text("Fermer")
                }
                .buttonStyle(RPGhostButtonStyle())
            }
            .padding(.horizontal, RPTheme.Spacing.md)
            .opacity(contentOpacity)
        }
        .padding(.vertical, RPTheme.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RPTheme.backgroundPrimary)
        .sensoryFeedback(.success, trigger: hapticTrigger)
        .sensoryFeedback(.impact(weight: .heavy), trigger: activationHaptic)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                checkmarkScale = 1
                checkmarkOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.4)) {
                contentOpacity = 1
            }
            hapticTrigger += 1
        }
    }

    private func activateCard() {
        withAnimation(.spring(response: 0.5)) {
            cardActivating = true
        }
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                cardActivating = false
                cardActivated = true
            }
            activationHaptic += 1
        }
    }

    private var checkmarkCircle: some View {
        ZStack {
            Circle()
                .fill(Color.green.opacity(0.12))
                .frame(width: 120, height: 120)
            Circle()
                .fill(Color.green.opacity(0.2))
                .frame(width: 90, height: 90)
            Image(systemName: "checkmark")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(.green)
        }
        .scaleEffect(checkmarkScale)
        .opacity(checkmarkOpacity)
    }

    private var activatingVisual: some View {
        ZStack {
            Circle()
                .fill(RPTheme.accent.opacity(0.1))
                .frame(width: 120, height: 120)
            Circle()
                .fill(RPTheme.accent.opacity(0.15))
                .frame(width: 90, height: 90)
            ProgressView()
                .controlSize(.large)
                .tint(RPTheme.accent)
        }
    }

    private var activatedCardVisual: some View {
        ZStack {
            Circle()
                .fill(RPTheme.accent.opacity(0.1))
                .frame(width: 120, height: 120)
            Circle()
                .fill(RPTheme.accent.opacity(0.18))
                .frame(width: 90, height: 90)
            Image(systemName: "creditcard.fill")
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(RPTheme.accent)
        }
    }

    private var bookingDetails: some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            detailRow(icon: "calendar", label: "Durée", value: formatDates)
            detailRow(icon: "banknote", label: "Montant", value: booking.totalAmount)
            detailRow(icon: "lock.shield", label: "Caution", value: booking.depositAmount)
        }
        .padding(RPTheme.Spacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: RPTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(RPTheme.accent)
                .frame(width: 28)
            Text(label)
                .font(.system(.subheadline, design: .default))
                .foregroundStyle(RPTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .default, weight: .semibold))
                .foregroundStyle(RPTheme.textPrimary)
        }
    }

    private var formatDates: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "d MMM"
        return "\(formatter.string(from: booking.startDate)) – \(formatter.string(from: booking.endDate))"
    }

    private var qrAccessCard: some View {
        VStack(spacing: RPTheme.Spacing.md) {
            Image(systemName: "qrcode")
                .font(.system(size: 80))
                .foregroundStyle(RPTheme.textPrimary)

            Text("QR d'accès généré")
                .font(.system(.caption, design: .default, weight: .semibold))
                .foregroundStyle(RPTheme.accent)

            Text("Activez votre carte NFC pour déverrouiller l'accès")
                .font(.system(.caption2, design: .default))
                .foregroundStyle(RPTheme.textSecondary)
        }
        .padding(RPTheme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private var smartCardPreview: some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
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
                    .frame(height: 90)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(RPTheme.accent.opacity(0.3), lineWidth: 1)
                    }

                HStack(spacing: RPTheme.Spacing.md) {
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 18))
                        .foregroundStyle(RPTheme.accent)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("ROUTEPASS")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(RPTheme.accent)
                            .tracking(2)

                        Text(booking.item.name)
                            .font(.system(.subheadline, design: .default, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }

                    Spacer()

                    HStack(spacing: 5) {
                        Circle()
                            .fill(.green)
                            .frame(width: 6, height: 6)
                            .shadow(color: .green.opacity(0.6), radius: 3)
                        Text("Active")
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                            .foregroundStyle(.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green.opacity(0.15))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, RPTheme.Spacing.lg)
            }

            HStack(spacing: RPTheme.Spacing.xs) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(.green)
                Text("Serrure déverrouillée · Électricité activée")
                    .font(.system(.caption2, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }
        }
        .padding(.horizontal, RPTheme.Spacing.md)
    }
}
