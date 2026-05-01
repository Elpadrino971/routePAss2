import SwiftUI

struct PaymentConfirmationView: View {
    let code: String
    let providerName: String
    let provider: Provider?
    let onDismiss: () -> Void
    let onShowMap: () -> Void

    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var codeCopied: Bool = false
    @State private var hapticTrigger: Int = 0

    var body: some View {
        VStack(spacing: RPTheme.Spacing.xl) {
            Spacer()

            checkmarkCircle

            VStack(spacing: RPTheme.Spacing.sm) {
                Text("Paiement validé")
                    .font(.system(.title2, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Text("Votre course avec \(providerName) est confirmée")
                    .font(.system(.subheadline, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(contentOpacity)

            codeCard
                .opacity(contentOpacity)

            Text("Le prestataire valide votre code")
                .font(.system(.footnote, design: .default))
                .foregroundStyle(RPTheme.textSecondary)
                .opacity(contentOpacity)

            Spacer()

            VStack(spacing: RPTheme.Spacing.sm) {
                Button {
                    onShowMap()
                } label: {
                    HStack(spacing: RPTheme.Spacing.sm) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 16))
                        Text("Suivre sur la carte")
                    }
                }
                .buttonStyle(RPPrimaryButtonStyle())

                Button {
                    onDismiss()
                } label: {
                    Text("Terminé")
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

    private var codeCard: some View {
        Button {
            UIPasteboard.general.string = code
            withAnimation(.snappy) {
                codeCopied = true
            }
            Task {
                try? await Task.sleep(for: .seconds(2))
                withAnimation { codeCopied = false }
            }
        } label: {
            VStack(spacing: RPTheme.Spacing.sm) {
                Text("Votre code")
                    .font(.system(.caption, design: .default, weight: .medium))
                    .foregroundStyle(RPTheme.textSecondary)
                    .textCase(.uppercase)

                HStack(spacing: 12) {
                    ForEach(Array(code), id: \.self) { char in
                        Text(String(char))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(RPTheme.textPrimary)
                            .frame(width: 52, height: 64)
                            .background(Color(.tertiarySystemFill))
                            .clipShape(.rect(cornerRadius: 12))
                    }
                }

                HStack(spacing: 4) {
                    Image(systemName: codeCopied ? "checkmark" : "doc.on.doc")
                        .font(.caption2)
                    Text(codeCopied ? "Copié !" : "Touchez pour copier")
                        .font(.system(.caption, design: .default))
                }
                .foregroundStyle(codeCopied ? .green : RPTheme.textSecondary)
            }
            .padding(RPTheme.Spacing.lg)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        }
        .padding(.horizontal, RPTheme.Spacing.md)
    }
}
