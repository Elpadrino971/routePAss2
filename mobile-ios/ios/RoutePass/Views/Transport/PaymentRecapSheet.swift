import SwiftUI

struct PaymentRecapSheet: View {
    let provider: Provider
    let isProcessing: Bool
    let onPayApplePay: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RPTheme.Spacing.lg) {
                    providerSection
                    Divider()
                    serviceSection
                    Divider()
                    priceSection
                    paymentButtons
                }
                .padding(.horizontal, RPTheme.Spacing.md)
                .padding(.top, RPTheme.Spacing.md)
                .padding(.bottom, RPTheme.Spacing.xl)
            }
            .navigationTitle("Récapitulatif")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { onDismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationContentInteraction(.scrolls)
    }

    private var providerSection: some View {
        HStack(spacing: RPTheme.Spacing.md) {
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: provider.avatarSystemName)
                    .font(.system(size: 40))
                    .foregroundStyle(RPTheme.accent.opacity(0.7))
                    .frame(width: 64, height: 64)
                    .background(RPTheme.accent.opacity(0.1))
                    .clipShape(Circle())

                if provider.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(RPTheme.accent)
                        .background(Circle().fill(Color(.systemBackground)).frame(width: 18, height: 18))
                        .offset(x: 2, y: 2)
                }
            }

            VStack(alignment: .leading, spacing: RPTheme.Spacing.xs) {
                Text(provider.name)
                    .font(.system(.headline, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Text(provider.vehicleType)
                    .font(.system(.subheadline, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text(String(format: "%.1f", provider.rating))
                        .font(.system(.caption, design: .default, weight: .semibold))
                    Text("(\(provider.reviewCount) avis)")
                        .font(.system(.caption, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                }
            }

            Spacer()
        }
    }

    private var serviceSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.sm) {
            Text("Service")
                .font(.system(.caption, design: .default, weight: .semibold))
                .foregroundStyle(RPTheme.textSecondary)
                .textCase(.uppercase)

            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(RPTheme.accent)
                Text("Course standard")
                    .font(.system(.body, design: .default))
                Spacer()
            }
        }
    }

    private var priceSection: some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            HStack {
                Text("Tarif course")
                    .font(.system(.body, design: .default))
                    .foregroundStyle(RPTheme.textPrimary)
                Spacer()
                Text(provider.tarif)
                    .font(.system(.body, design: .default, weight: .semibold))
            }
            HStack {
                Text("Commission RoutePass")
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
                Spacer()
                Text("10%")
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }
            Divider()
            HStack {
                Text("Total")
                    .font(.system(.title3, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)
                Spacer()
                Text(provider.tarif)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(RPTheme.accent)
            }
        }
        .padding(RPTheme.Spacing.md)
        .background(Color(.tertiarySystemFill))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var paymentButtons: some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            Button {
                onPayApplePay()
            } label: {
                HStack(spacing: RPTheme.Spacing.sm) {
                    if isProcessing {
                        ProgressView()
                            .tint(.white)
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
