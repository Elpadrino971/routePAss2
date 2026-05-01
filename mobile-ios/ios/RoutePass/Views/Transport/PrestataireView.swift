import SwiftUI

struct PrestataireView: View {
    @State private var viewModel = TransportViewModel()
    @State private var showCodeInput: Bool = false
    @State private var inputCode: String = ""
    @State private var validationResult: Bool?
    @State private var hapticTrigger: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: RPTheme.Spacing.lg) {
                qrSection
                balanceSection
                actionsSection
                todayTripsSection
            }
            .padding(.bottom, 80)
        }
        .scrollIndicators(.hidden)
        .sensoryFeedback(.success, trigger: hapticTrigger)
        .sheet(isPresented: $showCodeInput) {
            codeValidationSheet
        }
    }

    private var qrSection: some View {
        VStack(spacing: RPTheme.Spacing.md) {
            Text("Mon QR Code")
                .font(.system(.caption, design: .default, weight: .semibold))
                .foregroundStyle(RPTheme.textSecondary)
                .textCase(.uppercase)

            VStack(spacing: RPTheme.Spacing.md) {
                Image(systemName: "qrcode")
                    .font(.system(size: 140))
                    .foregroundStyle(RPTheme.textPrimary)

                Text("ROUTEPASS")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(RPTheme.accent)
                    .tracking(2)
            }
            .padding(RPTheme.Spacing.xl)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
            .shadow(color: RPTheme.cardShadow, radius: RPTheme.cardShadowRadius, x: 0, y: RPTheme.cardShadowY)
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .padding(.top, RPTheme.Spacing.lg)
    }

    private var balanceSection: some View {
        VStack(spacing: RPTheme.Spacing.sm) {
            Text("Solde du jour")
                .font(.system(.caption, design: .default, weight: .semibold))
                .foregroundStyle(RPTheme.textSecondary)
                .textCase(.uppercase)

            Text(viewModel.dailySummary.totalEarnings)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(RPTheme.accent)

            Text("\(viewModel.dailySummary.tripCount) courses aujourd'hui")
                .font(.system(.subheadline, design: .default))
                .foregroundStyle(RPTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, RPTheme.Spacing.lg)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: RPTheme.cardRadius))
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private var actionsSection: some View {
        Button {
            showCodeInput = true
        } label: {
            HStack(spacing: RPTheme.Spacing.sm) {
                Image(systemName: "number.square.fill")
                    .font(.system(size: 20))
                Text("Valider un code")
                    .font(.system(.body, design: .rounded, weight: .semibold))
            }
        }
        .buttonStyle(RPPrimaryButtonStyle())
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private var todayTripsSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Courses validées aujourd'hui")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)
                .padding(.horizontal, RPTheme.Spacing.md)

            VStack(spacing: RPTheme.Spacing.sm) {
                ForEach(viewModel.dailySummary.trips) { trip in
                    TripRow(trip: trip)
                }
            }
            .padding(.horizontal, RPTheme.Spacing.md)
        }
    }

    private var codeValidationSheet: some View {
        NavigationStack {
            VStack(spacing: RPTheme.Spacing.xl) {
                VStack(spacing: RPTheme.Spacing.sm) {
                    Text("Entrez le code client")
                        .font(.system(.title3, design: .default, weight: .bold))
                        .foregroundStyle(RPTheme.textPrimary)

                    Text("Le client vous communique son code à 4 chiffres")
                        .font(.system(.subheadline, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { index in
                        let char = index < inputCode.count ? String(Array(inputCode)[index]) : ""
                        Text(char)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(RPTheme.textPrimary)
                            .frame(width: 56, height: 72)
                            .background(Color(.tertiarySystemFill))
                            .clipShape(.rect(cornerRadius: 14))
                    }
                }

                if let result = validationResult {
                    HStack(spacing: 6) {
                        Image(systemName: result ? "checkmark.circle.fill" : "xmark.circle.fill")
                        Text(result ? "Code validé !" : "Code invalide")
                    }
                    .font(.system(.subheadline, design: .default, weight: .semibold))
                    .foregroundStyle(result ? .green : .red)
                }

                codeKeypad
            }
            .padding(.horizontal, RPTheme.Spacing.md)
            .padding(.top, RPTheme.Spacing.lg)
            .navigationTitle("Validation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        showCodeInput = false
                        inputCode = ""
                        validationResult = nil
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var codeKeypad: some View {
        let keys: [[String]] = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            ["", "0", "⌫"]
        ]

        return VStack(spacing: RPTheme.Spacing.sm) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: RPTheme.Spacing.sm) {
                    ForEach(row, id: \.self) { key in
                        if key.isEmpty {
                            Color.clear.frame(height: 56)
                        } else {
                            Button {
                                handleKeyPress(key)
                            } label: {
                                Group {
                                    if key == "⌫" {
                                        Image(systemName: "delete.backward.fill")
                                            .font(.system(size: 20))
                                    } else {
                                        Text(key)
                                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                                    }
                                }
                                .foregroundStyle(RPTheme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(.tertiarySystemFill))
                                .clipShape(.rect(cornerRadius: 12))
                            }
                        }
                    }
                }
            }
        }
    }

    private func handleKeyPress(_ key: String) {
        if key == "⌫" {
            if !inputCode.isEmpty {
                inputCode.removeLast()
                validationResult = nil
            }
        } else if inputCode.count < 4 {
            inputCode += key
            if inputCode.count == 4 {
                let valid = viewModel.validateCode(inputCode)
                validationResult = valid
                if valid {
                    hapticTrigger += 1
                }
            }
        }
    }
}

struct TripRow: View {
    let trip: Trip
    @State private var appeared: Bool = false

    var body: some View {
        HStack(spacing: RPTheme.Spacing.md) {
            Circle()
                .fill(Color.green.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.green)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(trip.serviceName)
                    .font(.system(.subheadline, design: .default, weight: .medium))
                    .foregroundStyle(RPTheme.textPrimary)
                    .lineLimit(1)

                Text(trip.timestamp, style: .time)
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(trip.netAmount)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(RPTheme.accent)

                Text("Code: \(trip.code)")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(RPTheme.textSecondary)
            }
        }
        .padding(RPTheme.Spacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 14))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
}
