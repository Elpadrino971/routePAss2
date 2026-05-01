import SwiftUI

struct BookingFlowSheet: View {
    let item: RentalItem
    @Binding var startDate: Date
    @Binding var endDate: Date
    let durationText: String
    let totalAmount: String
    let isProcessing: Bool
    let onConfirm: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RPTheme.Spacing.lg) {
                    itemSummary
                    Divider()
                    dateSelection
                    Divider()
                    recap
                    paymentSection
                }
                .padding(.horizontal, RPTheme.Spacing.md)
                .padding(.top, RPTheme.Spacing.md)
                .padding(.bottom, RPTheme.Spacing.xl)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Réservation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { onDismiss() }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationContentInteraction(.scrolls)
    }

    private var itemSummary: some View {
        HStack(spacing: RPTheme.Spacing.md) {
            Image(systemName: item.icon)
                .font(.system(size: 28))
                .foregroundStyle(RPTheme.accent.opacity(0.6))
                .frame(width: 56, height: 56)
                .background(RPTheme.accent.opacity(0.08))
                .clipShape(.rect(cornerRadius: 14))

            VStack(alignment: .leading, spacing: RPTheme.Spacing.xs) {
                Text(item.name)
                    .font(.system(.headline, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                HStack(spacing: 4) {
                    if item.ownerVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption2)
                            .foregroundStyle(RPTheme.accent)
                    }
                    Text(item.ownerName)
                        .font(.system(.caption, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                }
            }

            Spacer()
        }
    }

    private var dateSelection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Dates")
                .font(.system(.caption, design: .default, weight: .semibold))
                .foregroundStyle(RPTheme.textSecondary)
                .textCase(.uppercase)

            VStack(spacing: RPTheme.Spacing.sm) {
                DatePicker("Début", selection: $startDate, in: Date()..., displayedComponents: .date)
                    .font(.system(.body, design: .default))
                    .tint(RPTheme.accent)

                DatePicker("Fin", selection: $endDate, in: startDate.addingTimeInterval(86400)..., displayedComponents: .date)
                    .font(.system(.body, design: .default))
                    .tint(RPTheme.accent)
            }
        }
    }

    private var recap: some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            recapRow(label: "Durée", value: durationText)
            recapRow(label: "Tarif location", value: totalAmount)
            recapRow(label: "Caution (bloquée)", value: item.deposit)

            HStack {
                Text("Commission RoutePass")
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
                Spacer()
                Text("5%")
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }

            Divider()

            HStack {
                Text("Total")
                    .font(.system(.title3, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)
                Spacer()
                Text(totalAmount)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(RPTheme.accent)
            }
        }
        .padding(RPTheme.Spacing.md)
        .background(Color(.tertiarySystemFill))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func recapRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(.body, design: .default))
                .foregroundStyle(RPTheme.textPrimary)
            Spacer()
            Text(value)
                .font(.system(.body, design: .default, weight: .semibold))
        }
    }

    private var paymentSection: some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            Button {
                onConfirm()
            } label: {
                HStack(spacing: RPTheme.Spacing.sm) {
                    if isProcessing {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 18))
                        Text("Payer avec Apple Pay")
                            .font(.system(.body, design: .default, weight: .semibold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.black)
                .clipShape(.rect(cornerRadius: RPTheme.buttonRadius))
            }
            .disabled(isProcessing)

            Button {} label: {
                Text("Autre moyen de paiement")
                    .font(.system(.subheadline, design: .default, weight: .medium))
                    .foregroundStyle(RPTheme.textSecondary)
            }
        }
    }
}
