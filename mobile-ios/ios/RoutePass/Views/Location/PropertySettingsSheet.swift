import SwiftUI

struct PropertySettingsSheet: View {
    let item: RentalItem
    @Binding var cleaningMinutes: Int
    @Environment(\.dismiss) private var dismiss

    @State private var pricePerDay: String = "180"
    @State private var pricePerWeek: String = "950"
    @State private var pricePerMonth: String = "2 400"
    @State private var depositAmount: String = "2 400"
    @State private var blockDatesEnabled: Bool = false
    @State private var hapticTrigger: Int = 0

    var body: some View {
        NavigationStack {
            List {
                Section("Tarifs (€)") {
                    LabeledContent("Par jour") {
                        TextField("", text: $pricePerDay)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(RPTheme.accent)
                    }
                    LabeledContent("Par semaine") {
                        TextField("", text: $pricePerWeek)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(RPTheme.accent)
                    }
                    LabeledContent("Par mois") {
                        TextField("", text: $pricePerMonth)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(RPTheme.accent)
                    }
                }

                Section("Caution") {
                    LabeledContent("Montant (€)") {
                        TextField("", text: $depositAmount)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(RPTheme.accent)
                    }
                }

                Section("Nettoyage") {
                    Stepper(
                        "Durée : \(cleaningMinutes) min",
                        value: $cleaningMinutes,
                        in: 15...300,
                        step: 15
                    )
                }

                Section("Blocage de dates") {
                    Toggle("Bloquer les réservations", isOn: $blockDatesEnabled)
                        .tint(RPTheme.accent)

                    if blockDatesEnabled {
                        Text("Les nouvelles réservations seront refusées jusqu'à réactivation.")
                            .font(.system(.caption, design: .default))
                            .foregroundStyle(RPTheme.textSecondary)
                    }
                }
            }
            .navigationTitle("Paramètres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sauvegarder") {
                        hapticTrigger += 1
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(RPTheme.accent)
                }
            }
            .sensoryFeedback(.success, trigger: hapticTrigger)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
