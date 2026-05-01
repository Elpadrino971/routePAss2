import SwiftUI

struct ToolBookingFlowSheet: View {
    let tool: ToolItem
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var addInsurance: Bool
    let durationText: String
    let totalAmount: String
    let insuranceAmount: String
    let isProcessing: Bool
    let onConfirm: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RPTheme.Spacing.lg) {
                    toolSummary
                    Divider()
                    dateSelection
                    Divider()
                    insuranceToggle
                    Divider()
                    recap
                    paymentSection
                }
                .padding(.horizontal, RPTheme.Spacing.md)
                .padding(.top, RPTheme.Spacing.md)
                .padding(.bottom, RPTheme.Spacing.xl)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Réservation outil")
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

    private var toolSummary: some View {
        HStack(spacing: RPTheme.Spacing.md) {
            Image(systemName: tool.icon)
                .font(.system(size: 28))
                .foregroundStyle(RPTheme.accent.opacity(0.6))
                .frame(width: 56, height: 56)
                .background(RPTheme.accent.opacity(0.08))
                .clipShape(.rect(cornerRadius: 14))

            VStack(alignment: .leading, spacing: RPTheme.Spacing.xs) {
                Text(tool.name)
                    .font(.system(.headline, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)
                HStack(spacing: 4) {
                    Text("\(tool.brand) · \(tool.model)")
                        .font(.system(.caption, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                }
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: tool.condition.icon)
                    .font(.system(size: 10))
                Text(tool.condition.rawValue)
                    .font(.system(.caption2, design: .default, weight: .medium))
            }
            .foregroundStyle(tool.condition.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tool.condition.color.opacity(0.12))
            .clipShape(Capsule())
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

    private var insuranceToggle: some View {
        HStack(spacing: RPTheme.Spacing.md) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 18))
                .foregroundStyle(.blue)
                .frame(width: 36, height: 36)
                .background(Color.blue.opacity(0.1))
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text("Assurance casse")
                    .font(.system(.subheadline, design: .default, weight: .semibold))
                    .foregroundStyle(RPTheme.textPrimary)
                Text("+\(Int(tool.insuranceRate * 100))% · \(insuranceAmount)")
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }

            Spacer()

            Toggle("", isOn: $addInsurance)
                .tint(RPTheme.accent)
                .labelsHidden()
        }
    }

    private var recap: some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            recapRow(label: "Durée", value: durationText)
            recapRow(label: "Tarif location", value: totalAmount)
            recapRow(label: "Caution (Stripe Hold)", value: tool.deposit)

            if addInsurance {
                recapRow(label: "Assurance casse", value: insuranceAmount)
            }

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
