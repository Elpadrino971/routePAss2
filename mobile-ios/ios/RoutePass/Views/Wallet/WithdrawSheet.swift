import SwiftUI

struct WithdrawSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amount: String = ""
    @State private var isProcessing: Bool = false
    @State private var isSuccess: Bool = false

    var body: some View {
        VStack(spacing: RPTheme.Spacing.lg) {
            VStack(spacing: RPTheme.Spacing.sm) {
                Text("Retirer des fonds")
                    .font(.system(.title3, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Text("Solde disponible : \(WalletMockData.availableBalance)")
                    .font(.system(.subheadline, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }

            if isSuccess {
                successContent
            } else {
                formContent
            }
        }
        .padding(.top, RPTheme.Spacing.lg)
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private var formContent: some View {
        VStack(spacing: RPTheme.Spacing.lg) {
            VStack(alignment: .leading, spacing: RPTheme.Spacing.sm) {
                Text("Montant")
                    .font(.system(.subheadline, design: .default, weight: .medium))
                    .foregroundStyle(RPTheme.textSecondary)

                HStack {
                    TextField("0", text: $amount)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(RPTheme.textPrimary)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)

                    Text("€")
                        .font(.system(.title3, design: .rounded, weight: .medium))
                        .foregroundStyle(RPTheme.textSecondary)
                }
                .padding(.vertical, RPTheme.Spacing.md)
                .padding(.horizontal, RPTheme.Spacing.md)
                .background(Color(.tertiarySystemFill))
                .clipShape(.rect(cornerRadius: RPTheme.buttonRadius))
            }

            HStack(spacing: RPTheme.Spacing.sm) {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(RPTheme.textSecondary)
                Text("Vers compte bancaire •••4521")
                    .font(.system(.subheadline, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(RPTheme.textSecondary.opacity(0.5))
            }
            .padding(RPTheme.Spacing.md)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: RPTheme.buttonRadius))

            Button {
                withAnimation(.spring(response: 0.4)) {
                    isProcessing = true
                }
                Task {
                    try? await Task.sleep(for: .seconds(1.5))
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        isProcessing = false
                        isSuccess = true
                    }
                }
            } label: {
                if isProcessing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Confirmer le retrait")
                }
            }
            .buttonStyle(RPPrimaryButtonStyle())
            .disabled(amount.isEmpty || isProcessing)
            .opacity(amount.isEmpty ? 0.5 : 1)
            .sensoryFeedback(.success, trigger: isSuccess)

            Spacer()
        }
    }

    private var successContent: some View {
        VStack(spacing: RPTheme.Spacing.lg) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: isSuccess)

            VStack(spacing: RPTheme.Spacing.sm) {
                Text("Virement initié")
                    .font(.system(.title3, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Text("Votre virement sera traité sous 24h.")
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
}
