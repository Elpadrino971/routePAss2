import SwiftUI

struct BatchPayoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isProcessing: Bool = false
    @State private var progress: Double = 0
    @State private var isComplete: Bool = false

    var body: some View {
        VStack(spacing: RPTheme.Spacing.lg) {
            VStack(spacing: RPTheme.Spacing.sm) {
                Text("Virements du soir")
                    .font(.system(.title3, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Text("Déclencher les paiements pour tous les prestataires éligibles.")
                    .font(.system(.subheadline, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if isComplete {
                completeContent
            } else if isProcessing {
                processingContent
            } else {
                confirmContent
            }
        }
        .padding(.top, RPTheme.Spacing.lg)
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private var confirmContent: some View {
        VStack(spacing: RPTheme.Spacing.lg) {
            VStack(spacing: 1) {
                BatchInfoRow(label: "Prestataires éligibles", value: "34")
                BatchInfoRow(label: "Montant total", value: "18 700 €")
                BatchInfoRow(label: "Commission retenue", value: "935 €")
                BatchInfoRow(label: "Net à verser", value: "17 765 €")
            }
            .clipShape(.rect(cornerRadius: RPTheme.buttonRadius))

            Spacer()

            Button {
                withAnimation(.spring(response: 0.4)) {
                    isProcessing = true
                }
                startBatchProcess()
            } label: {
                Text("Lancer les virements")
            }
            .buttonStyle(RPPrimaryButtonStyle())
            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.7), trigger: isProcessing)
        }
    }

    private var processingContent: some View {
        VStack(spacing: RPTheme.Spacing.lg) {
            Spacer()

            VStack(spacing: RPTheme.Spacing.md) {
                ProgressView(value: progress)
                    .tint(RPTheme.accent)
                    .scaleEffect(y: 2)

                Text("\(Int(progress * 34))/34 prestataires traités")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(RPTheme.textSecondary)
            }

            Spacer()
        }
    }

    private var completeContent: some View {
        VStack(spacing: RPTheme.Spacing.lg) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: isComplete)

            VStack(spacing: RPTheme.Spacing.sm) {
                Text("Virements effectués")
                    .font(.system(.title3, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Text("34 prestataires payés\n17 765 € versés")
                    .font(.system(.subheadline, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button("Fermer") {
                dismiss()
            }
            .buttonStyle(RPSecondaryButtonStyle())
        }
    }

    private func startBatchProcess() {
        Task {
            for i in 1...34 {
                try? await Task.sleep(for: .milliseconds(60))
                withAnimation(.linear(duration: 0.05)) {
                    progress = Double(i) / 34.0
                }
            }
            try? await Task.sleep(for: .seconds(0.3))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isProcessing = false
                isComplete = true
            }
        }
    }
}

struct BatchInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(.subheadline, design: .default))
                .foregroundStyle(RPTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(RPTheme.textPrimary)
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground))
    }
}
