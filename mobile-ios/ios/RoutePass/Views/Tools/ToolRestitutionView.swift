import SwiftUI

struct ToolRestitutionView: View {
    let booking: ToolBooking
    @Binding var checklist: RestitutionChecklist
    let onConfirm: () -> Void
    let onDismiss: () -> Void

    @State private var showDamageSlider: Bool = false
    @State private var hapticTrigger: Int = 0
    @State private var isProcessing: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RPTheme.Spacing.lg) {
                    toolHeader
                    photosSection
                    checklistSection
                    if showDamageSlider {
                        damageSection
                    }
                    cautionResult
                    confirmButton
                }
                .padding(.horizontal, RPTheme.Spacing.md)
                .padding(.top, RPTheme.Spacing.md)
                .padding(.bottom, RPTheme.Spacing.xl)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Restitution")
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
        .sensoryFeedback(.success, trigger: hapticTrigger)
    }

    private var toolHeader: some View {
        HStack(spacing: RPTheme.Spacing.md) {
            Image(systemName: booking.tool.icon)
                .font(.system(size: 28))
                .foregroundStyle(RPTheme.accent.opacity(0.6))
                .frame(width: 56, height: 56)
                .background(RPTheme.accent.opacity(0.08))
                .clipShape(.rect(cornerRadius: 14))

            VStack(alignment: .leading, spacing: RPTheme.Spacing.xs) {
                Text(booking.tool.name)
                    .font(.system(.headline, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)
                Text("\(booking.tool.brand) · \(booking.tool.model)")
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }

            Spacer()

            RPBadge(status: .nettoyage)
        }
    }

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Photos de restitution")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)

            Text("Prenez des photos avant et après pour documenter l'état de l'outil")
                .font(.system(.caption, design: .default))
                .foregroundStyle(RPTheme.textSecondary)

            HStack(spacing: RPTheme.Spacing.md) {
                photoUploadCard(label: "Avant", count: checklist.beforePhotos.count, icon: "camera.fill")
                photoUploadCard(label: "Après", count: checklist.afterPhotos.count, icon: "camera.badge.clock.fill")
            }
        }
    }

    private func photoUploadCard(label: String, count: Int, icon: String) -> some View {
        Button {
            if label == "Avant" {
                checklist.beforePhotos.append("photo_\(count + 1)")
            } else {
                checklist.afterPhotos.append("photo_\(count + 1)")
            }
        } label: {
            VStack(spacing: RPTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(RPTheme.accent)

                Text(label)
                    .font(.system(.subheadline, design: .default, weight: .semibold))
                    .foregroundStyle(RPTheme.textPrimary)

                if count > 0 {
                    Text("\(count) photo\(count > 1 ? "s" : "")")
                        .font(.system(.caption2, design: .default))
                        .foregroundStyle(.green)
                } else {
                    Text("Ajouter")
                        .font(.system(.caption2, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, RPTheme.Spacing.lg)
            .background(Color(.tertiarySystemFill))
            .clipShape(.rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(count > 0 ? Color.green.opacity(0.3) : .clear, lineWidth: 1.5)
            )
        }
    }

    private var checklistSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("État de l'outil")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)

            VStack(spacing: RPTheme.Spacing.sm) {
                checklistRow(
                    label: "Propre",
                    icon: "sparkles",
                    isChecked: $checklist.isClean
                )
                checklistRow(
                    label: "Fonctionnel",
                    icon: "checkmark.circle.fill",
                    isChecked: $checklist.isFunctional
                )
                checklistRow(
                    label: "Complet (accessoires)",
                    icon: "shippingbox.fill",
                    isChecked: $checklist.isComplete
                )
                checklistRow(
                    label: "Sans dommage visible",
                    icon: "shield.checkered",
                    isChecked: Binding(
                        get: { checklist.noDamage },
                        set: { newValue in
                            checklist.noDamage = newValue
                            withAnimation(.spring(response: 0.3)) {
                                showDamageSlider = !newValue
                            }
                            if newValue {
                                checklist.damageAmount = 0
                            }
                        }
                    )
                )
            }
        }
    }

    private func checklistRow(label: String, icon: String, isChecked: Binding<Bool>) -> some View {
        Button {
            isChecked.wrappedValue.toggle()
        } label: {
            HStack(spacing: RPTheme.Spacing.md) {
                Image(systemName: isChecked.wrappedValue ? "checkmark.square.fill" : "square")
                    .font(.system(size: 22))
                    .foregroundStyle(isChecked.wrappedValue ? .green : RPTheme.textSecondary)
                    .contentTransition(.symbolEffect(.replace))

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(RPTheme.accent)
                    .frame(width: 28)

                Text(label)
                    .font(.system(.body, design: .default))
                    .foregroundStyle(RPTheme.textPrimary)

                Spacer()
            }
            .padding(RPTheme.Spacing.md)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private var damageSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            HStack(spacing: RPTheme.Spacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.red)
                Text("Dommage constaté")
                    .font(.system(.headline, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)
            }

            Text("Ajustez le montant à déduire de la caution")
                .font(.system(.caption, design: .default))
                .foregroundStyle(RPTheme.textSecondary)

            VStack(spacing: RPTheme.Spacing.sm) {
                Text(formatDamageAmount)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.red)

                Slider(value: $checklist.damageAmount, in: 0...maxDamage, step: 5000)
                    .tint(.red)

                HStack {
                    Text("0 €")
                        .font(.system(.caption2, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                    Spacer()
                    Text(booking.tool.deposit)
                        .font(.system(.caption2, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                }
            }
            .padding(RPTheme.Spacing.md)
            .background(Color.red.opacity(0.06))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private var maxDamage: Double {
        let digits = booking.tool.deposit.filter { $0.isNumber }
        return Double(digits) ?? 500000
    }

    private var formatDamageAmount: String {
        let value = Int(checklist.damageAmount)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        let formatted = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(formatted) €"
    }

    private var cautionResult: some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            if checklist.allChecked {
                HStack(spacing: RPTheme.Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Caution libérée intégralement")
                            .font(.system(.subheadline, design: .default, weight: .semibold))
                            .foregroundStyle(.green)
                        Text(booking.tool.deposit)
                            .font(.system(.caption, design: .default))
                            .foregroundStyle(RPTheme.textSecondary)
                    }
                    Spacer()
                }
            } else if checklist.damageAmount > 0 {
                HStack(spacing: RPTheme.Spacing.sm) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Capture partielle Stripe")
                            .font(.system(.subheadline, design: .default, weight: .semibold))
                            .foregroundStyle(.orange)
                        Text("\(formatDamageAmount) déduits de la caution")
                            .font(.system(.caption, design: .default))
                            .foregroundStyle(RPTheme.textSecondary)
                    }
                    Spacer()
                }
            }
        }
        .padding(RPTheme.Spacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var confirmButton: some View {
        Button {
            isProcessing = true
            Task {
                try? await Task.sleep(for: .seconds(1))
                isProcessing = false
                hapticTrigger += 1
                onConfirm()
            }
        } label: {
            HStack(spacing: RPTheme.Spacing.sm) {
                if isProcessing {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                    Text("Confirmer la restitution")
                        .font(.system(.body, design: .rounded, weight: .semibold))
                }
            }
        }
        .buttonStyle(RPPrimaryButtonStyle())
        .disabled(isProcessing || (!checklist.beforePhotos.isEmpty && checklist.afterPhotos.isEmpty))
    }
}
