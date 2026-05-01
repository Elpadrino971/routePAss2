import SwiftUI
import MapKit

struct MarkerDetailSheet: View {
    let item: MapItem
    let isPaymentConfirmed: Bool
    let onRoute: () -> Void
    let onContact: () -> Void
    let onDismiss: () -> Void

    @State private var appearAnimation: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            handle

            ScrollView {
                VStack(spacing: RPTheme.Spacing.md) {
                    headerSection
                    statusRow
                    if isPaymentConfirmed {
                        addressSection
                    }
                    if let eta = item.eta, item.isTransportActive {
                        etaSection(eta: eta)
                    }
                    if let endDate = item.endDate {
                        timerSection(endDate: endDate)
                    }
                    actionsSection
                }
                .padding(.horizontal, RPTheme.Spacing.md)
                .padding(.bottom, RPTheme.Spacing.xl)
            }
            .scrollIndicators(.hidden)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .presentationContentInteraction(.scrolls)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appearAnimation = true
            }
        }
    }

    private var handle: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color(.tertiaryLabel))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 12)
        }
    }

    private var headerSection: some View {
        HStack(spacing: RPTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(item.category.markerColor.opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: item.category.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(item.category.markerColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(.title3, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Text(item.subtitle)
                    .font(.system(.subheadline, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text(String(format: "%.1f", item.rating))
                        .font(.system(.caption, design: .default, weight: .semibold))
                        .foregroundStyle(RPTheme.textPrimary)

                    Text("·")
                        .foregroundStyle(RPTheme.textSecondary)

                    Text(item.price)
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(RPTheme.accent)
                }
            }

            Spacer(minLength: 0)

            if item.ownerVerified {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title3)
                    .foregroundStyle(.blue)
            }
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 10)
    }

    private var statusRow: some View {
        HStack {
            RPBadge(status: item.status)

            Spacer()

            Text(item.category.label)
                .font(.system(.caption, design: .default, weight: .medium))
                .foregroundStyle(RPTheme.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color(.tertiarySystemFill))
                .clipShape(Capsule())
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 8)
    }

    private var addressSection: some View {
        HStack(spacing: RPTheme.Spacing.sm) {
            Image(systemName: "mappin.circle.fill")
                .font(.title3)
                .foregroundStyle(RPTheme.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text("Adresse")
                    .font(.system(.caption, design: .default, weight: .medium))
                    .foregroundStyle(RPTheme.textSecondary)
                    .textCase(.uppercase)

                Text(item.address.isEmpty ? "Adresse déverrouillée après paiement" : item.address)
                    .font(.system(.subheadline, design: .default, weight: .medium))
                    .foregroundStyle(RPTheme.textPrimary)
            }

            Spacer(minLength: 0)
        }
        .padding(RPTheme.Spacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 14))
        .opacity(appearAnimation ? 1 : 0)
    }

    private func etaSection(eta: String) -> some View {
        HStack(spacing: RPTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: "location.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.green)
                    .symbolEffect(.pulse)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("En approche")
                    .font(.system(.caption, design: .default, weight: .medium))
                    .foregroundStyle(RPTheme.textSecondary)
                    .textCase(.uppercase)

                Text("Arrivée dans \(eta)")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)
                    .contentTransition(.numericText())
            }

            Spacer(minLength: 0)
        }
        .padding(RPTheme.Spacing.md)
        .background(Color.green.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func timerSection(endDate: Date) -> some View {
        HStack(spacing: RPTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(RPTheme.accent.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: "timer")
                    .font(.system(size: 18))
                    .foregroundStyle(RPTheme.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Location en cours")
                    .font(.system(.caption, design: .default, weight: .medium))
                    .foregroundStyle(RPTheme.textSecondary)
                    .textCase(.uppercase)

                Text("Jusqu'au \(endDate, format: .dateTime.day().month(.abbreviated).hour().minute())")
                    .font(.system(.subheadline, design: .default, weight: .semibold))
                    .foregroundStyle(RPTheme.textPrimary)
            }

            Spacer(minLength: 0)
        }
        .padding(RPTheme.Spacing.md)
        .background(RPTheme.accent.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var actionsSection: some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            if isPaymentConfirmed {
                Button {
                    onRoute()
                } label: {
                    HStack(spacing: RPTheme.Spacing.sm) {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                            .font(.system(size: 16))
                        Text("Itinéraire")
                            .font(.system(.body, design: .rounded, weight: .semibold))
                    }
                }
                .buttonStyle(RPPrimaryButtonStyle())
            }

            Button {
                onContact()
            } label: {
                HStack(spacing: RPTheme.Spacing.sm) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 14))
                    Text("Contacter")
                        .font(.system(.body, design: .rounded, weight: .semibold))
                }
            }
            .buttonStyle(RPSecondaryButtonStyle())
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 12)
    }
}
