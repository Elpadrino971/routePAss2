import SwiftUI

struct ToolBookingConfirmationView: View {
    let booking: ToolBooking
    let onAccessView: () -> Void
    let onShowMap: () -> Void
    let onDismiss: () -> Void

    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var hapticTrigger: Int = 0

    var body: some View {
        VStack(spacing: RPTheme.Spacing.xl) {
            Spacer()

            checkmarkCircle

            VStack(spacing: RPTheme.Spacing.sm) {
                Text("Réservation confirmée")
                    .font(.system(.title2, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Text(booking.tool.name)
                    .font(.system(.subheadline, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }
            .opacity(contentOpacity)

            bookingDetails
                .opacity(contentOpacity)

            accessInfo
                .opacity(contentOpacity)

            Spacer()

            VStack(spacing: RPTheme.Spacing.sm) {
                Button {
                    onAccessView()
                } label: {
                    HStack(spacing: RPTheme.Spacing.sm) {
                        Image(systemName: booking.tool.accessMethod == .qrAccess ? "qrcode" : "mappin.and.ellipse")
                            .font(.system(size: 16))
                        Text("Accéder à l'outil")
                    }
                }
                .buttonStyle(RPPrimaryButtonStyle())

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

    private var bookingDetails: some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            detailRow(icon: "calendar", label: "Durée", value: formatDates)
            detailRow(icon: "banknote", label: "Montant", value: booking.totalAmount)
            detailRow(icon: "lock.shield", label: "Caution", value: booking.depositAmount)
            if booking.hasInsurance, let ins = booking.insuranceAmount {
                detailRow(icon: "shield.checkered", label: "Assurance", value: ins)
            }
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

    private var accessInfo: some View {
        VStack(spacing: RPTheme.Spacing.md) {
            Image(systemName: booking.tool.accessMethod == .qrAccess ? "qrcode" : "mappin.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(RPTheme.textPrimary)

            Text(booking.tool.accessMethod.rawValue)
                .font(.system(.caption, design: .default, weight: .semibold))
                .foregroundStyle(RPTheme.accent)

            Text(booking.tool.address)
                .font(.system(.caption2, design: .default))
                .foregroundStyle(RPTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(RPTheme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        .padding(.horizontal, RPTheme.Spacing.md)
    }
}
