import SwiftUI
import Combine

struct ToolAccessView: View {
    let booking: ToolBooking
    let onEndRental: () -> Void
    let onDismiss: () -> Void

    @State private var timeRemaining: TimeInterval = 0
    @State private var hapticTrigger: Int = 0
    @State private var qrPulse: Bool = false
    @State private var showEndConfirmation: Bool = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RPTheme.Spacing.lg) {
                    accessCodeSection
                    instructionsSection
                    timerSection
                    actionsSection
                }
                .padding(.bottom, RPTheme.Spacing.xl)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Accès outil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { onDismiss() }
                }
            }
            .alert("Restituer l'outil ?", isPresented: $showEndConfirmation) {
                Button("Annuler", role: .cancel) {}
                Button("Restituer", role: .destructive) {
                    onEndRental()
                }
            } message: {
                Text("Le propriétaire devra confirmer l'état de l'outil pour libérer la caution.")
            }
            .onReceive(timer) { _ in
                timeRemaining = max(0, booking.endDate.timeIntervalSince(Date()))
            }
            .onAppear {
                timeRemaining = max(0, booking.endDate.timeIntervalSince(Date()))
            }
        }
    }

    private var accessCodeSection: some View {
        VStack(spacing: RPTheme.Spacing.md) {
            Text(booking.tool.accessMethod == .qrAccess ? "QR Code d'accès" : "Point de retrait")
                .font(.system(.caption, design: .default, weight: .semibold))
                .foregroundStyle(RPTheme.textSecondary)
                .textCase(.uppercase)

            VStack(spacing: RPTheme.Spacing.md) {
                if booking.tool.accessMethod == .qrAccess {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(RPTheme.accent.opacity(qrPulse ? 0.3 : 0.1), lineWidth: 2)
                            .frame(width: 200, height: 200)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: qrPulse)
                        Image(systemName: "qrcode")
                            .font(.system(size: 140))
                            .foregroundStyle(RPTheme.textPrimary)
                    }
                    .onAppear { qrPulse = true }
                } else {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(RPTheme.accent)
                }

                Text(booking.tool.name)
                    .font(.system(.subheadline, design: .default, weight: .semibold))
                    .foregroundStyle(RPTheme.textPrimary)

                Text(booking.tool.address)
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
                    .multilineTextAlignment(.center)

                RPBadge(status: .occupe)
            }
            .padding(RPTheme.Spacing.xl)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
            .shadow(color: RPTheme.cardShadow, radius: RPTheme.cardShadowRadius, x: 0, y: RPTheme.cardShadowY)
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .padding(.top, RPTheme.Spacing.md)
    }

    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Instructions")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)

            VStack(spacing: RPTheme.Spacing.sm) {
                switch booking.tool.accessMethod {
                case .qrAccess:
                    instructionRow(step: "1", text: "Rendez-vous à l'adresse indiquée")
                    instructionRow(step: "2", text: "Scannez le boîtier avec ce QR code")
                    instructionRow(step: "3", text: "Récupérez l'outil")
                    instructionRow(step: "4", text: "Restituez dans le même boîtier en fin de location")
                case .mainPropre:
                    instructionRow(step: "1", text: "Contactez le propriétaire pour convenir du rendez-vous")
                    instructionRow(step: "2", text: "Vérifiez l'état de l'outil ensemble")
                    instructionRow(step: "3", text: "Utilisez votre code d'accès : \(booking.accessCode)")
                    instructionRow(step: "4", text: "Restituez en main propre au propriétaire")
                case .livraison:
                    instructionRow(step: "1", text: "L'outil sera livré à l'adresse convenue")
                    instructionRow(step: "2", text: "Vérifiez l'état à la réception")
                    instructionRow(step: "3", text: "La récupération sera organisée en fin de location")
                case .codeBoitier:
                    instructionRow(step: "1", text: "Rendez-vous à l'adresse indiquée")
                    instructionRow(step: "2", text: "Entrez le code : \(booking.accessCode)")
                    instructionRow(step: "3", text: "Récupérez l'outil dans le local")
                    instructionRow(step: "4", text: "Remettez en place en fin de location")
                }
            }
        }
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private func instructionRow(step: String, text: String) -> some View {
        HStack(spacing: RPTheme.Spacing.md) {
            Text(step)
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(RPTheme.accent)
                .clipShape(Circle())
            Text(text)
                .font(.system(.subheadline, design: .default))
                .foregroundStyle(RPTheme.textPrimary)
            Spacer(minLength: 0)
        }
        .padding(RPTheme.Spacing.sm)
    }

    private var timerSection: some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            Text("Temps restant")
                .font(.system(.caption, design: .default, weight: .semibold))
                .foregroundStyle(RPTheme.textSecondary)
                .textCase(.uppercase)

            Text(formatTime(timeRemaining))
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(timeRemaining < 3600 ? .red : RPTheme.accent)
                .monospacedDigit()
                .contentTransition(.numericText())

            Text("Jusqu'au \(formatEndDate)")
                .font(.system(.caption, design: .default))
                .foregroundStyle(RPTheme.textSecondary)

            if timeRemaining < 3600 && timeRemaining > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                    Text("Alerte : restitution bientôt due")
                        .font(.system(.caption, design: .default, weight: .medium))
                        .foregroundStyle(.red)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.red.opacity(0.1))
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, RPTheme.Spacing.lg)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private var actionsSection: some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            Button {
                showEndConfirmation = true
            } label: {
                HStack(spacing: RPTheme.Spacing.sm) {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .font(.system(size: 18))
                    Text("Restituer l'outil")
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
        .sensoryFeedback(.warning, trigger: hapticTrigger)
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

    private var formatEndDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "d MMM à HH:mm"
        return formatter.string(from: booking.endDate)
    }
}
