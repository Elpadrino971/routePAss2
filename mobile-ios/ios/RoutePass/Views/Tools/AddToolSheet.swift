import SwiftUI

struct AddToolSheet: View {
    let onDismiss: () -> Void

    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var model: String = ""
    @State private var year: String = ""
    @State private var selectedCategory: ToolCategory = .outilsManuels
    @State private var selectedCondition: ToolCondition = .bonEtat
    @State private var selectedSkillLevel: SkillLevel = .debutant
    @State private var pricePerDay: String = ""
    @State private var deposit: String = ""
    @State private var weight: String = ""
    @State private var dimensions: String = ""
    @State private var description: String = ""
    @State private var consumablesIncluded: Bool = false
    @State private var hasManual: Bool = false
    @State private var deliveryAvailable: Bool = false
    @State private var deliveryPrice: String = ""
    @State private var photoCount: Int = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RPTheme.Spacing.lg) {
                    photoSection
                    basicInfoSection
                    categorySection
                    specsSection
                    pricingFormSection
                    optionsSection
                }
                .padding(.horizontal, RPTheme.Spacing.md)
                .padding(.top, RPTheme.Spacing.md)
                .padding(.bottom, RPTheme.Spacing.xl)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Ajouter un outil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { onDismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Publier") { onDismiss() }
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .foregroundStyle(RPTheme.accent)
                        .disabled(name.isEmpty || pricePerDay.isEmpty)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationContentInteraction(.scrolls)
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Photos")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)

            ScrollView(.horizontal) {
                HStack(spacing: RPTheme.Spacing.sm) {
                    Button {
                        photoCount += 1
                    } label: {
                        VStack(spacing: RPTheme.Spacing.sm) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(RPTheme.accent)
                            Text("Ajouter")
                                .font(.system(.caption, design: .default, weight: .medium))
                                .foregroundStyle(RPTheme.textSecondary)
                        }
                        .frame(width: 100, height: 100)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(.rect(cornerRadius: 14))
                    }

                    ForEach(0..<photoCount, id: \.self) { index in
                        Color(RPTheme.accent.opacity(0.08))
                            .frame(width: 100, height: 100)
                            .overlay {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(RPTheme.accent.opacity(0.3))
                            }
                            .clipShape(.rect(cornerRadius: 14))
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    withAnimation { photoCount = max(0, photoCount - 1) }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(.white, .red)
                                }
                                .offset(x: 6, y: -6)
                            }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Informations de base")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)

            VStack(spacing: RPTheme.Spacing.sm) {
                formField(label: "Nom de l'outil", text: $name, placeholder: "Ex: Perceuse Bosch Pro")
                formField(label: "Marque", text: $brand, placeholder: "Ex: Bosch")
                formField(label: "Modèle", text: $model, placeholder: "Ex: GSB 18V-85 C")
                formField(label: "Année", text: $year, placeholder: "Ex: 2023")
            }
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Catégorie")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)

            ScrollView(.horizontal) {
                HStack(spacing: RPTheme.Spacing.sm) {
                    ForEach(ToolCategory.allCases) { cat in
                        Button {
                            selectedCategory = cat
                        } label: {
                            HStack(spacing: 6) {
                                Text(cat.emoji)
                                    .font(.system(size: 14))
                                Text(cat.rawValue)
                                    .font(.system(.caption, design: .default, weight: .medium))
                            }
                            .foregroundStyle(selectedCategory == cat ? .white : RPTheme.textPrimary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedCategory == cat ? RPTheme.accent : Color(.tertiarySystemFill))
                            .clipShape(Capsule())
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)

            VStack(alignment: .leading, spacing: RPTheme.Spacing.sm) {
                Text("État")
                    .font(.system(.caption, design: .default, weight: .semibold))
                    .foregroundStyle(RPTheme.textSecondary)

                Picker("État", selection: $selectedCondition) {
                    Text("Neuf").tag(ToolCondition.neuf)
                    Text("Bon état").tag(ToolCondition.bonEtat)
                    Text("Usure normale").tag(ToolCondition.usureNormale)
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: RPTheme.Spacing.sm) {
                Text("Niveau requis")
                    .font(.system(.caption, design: .default, weight: .semibold))
                    .foregroundStyle(RPTheme.textSecondary)

                Picker("Niveau", selection: $selectedSkillLevel) {
                    Text("Débutant").tag(SkillLevel.debutant)
                    Text("Intermédiaire").tag(SkillLevel.intermediaire)
                    Text("Pro").tag(SkillLevel.professionnel)
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var specsSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Spécifications")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)

            VStack(spacing: RPTheme.Spacing.sm) {
                formField(label: "Poids", text: $weight, placeholder: "Ex: 2.1 kg")
                formField(label: "Dimensions", text: $dimensions, placeholder: "Ex: 20 × 8 × 25 cm")
            }

            VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
                Text("Description")
                    .font(.system(.caption, design: .default, weight: .semibold))
                    .foregroundStyle(RPTheme.textSecondary)

                TextEditor(text: $description)
                    .font(.system(.body, design: .default))
                    .frame(minHeight: 80)
                    .padding(RPTheme.Spacing.sm)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(.rect(cornerRadius: 12))
            }
        }
    }

    private var pricingFormSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Tarification")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)

            VStack(spacing: RPTheme.Spacing.sm) {
                formField(label: "Prix par jour (€)", text: $pricePerDay, placeholder: "Ex: 35")
                formField(label: "Caution (€)", text: $deposit, placeholder: "Ex: 350")
            }

            HStack(spacing: RPTheme.Spacing.sm) {
                Image(systemName: "tag.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                Text("Prix dégressifs automatiques : −10% semaine / −20% mois")
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }
        }
    }

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Options")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)

            VStack(spacing: RPTheme.Spacing.sm) {
                toggleRow(label: "Consommables inclus", icon: "shippingbox.fill", isOn: $consumablesIncluded)
                toggleRow(label: "Manuel d'utilisation", icon: "doc.text.fill", isOn: $hasManual)
                toggleRow(label: "Livraison disponible", icon: "truck.box.fill", isOn: $deliveryAvailable)
            }

            if deliveryAvailable {
                formField(label: "Tarif livraison (€)", text: $deliveryPrice, placeholder: "Ex: 80")
            }
        }
    }

    private func formField(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(.caption, design: .default, weight: .semibold))
                .foregroundStyle(RPTheme.textSecondary)
            TextField(placeholder, text: text)
                .font(.system(.body, design: .default))
                .padding(12)
                .background(Color(.tertiarySystemFill))
                .clipShape(.rect(cornerRadius: 12))
        }
    }

    private func toggleRow(label: String, icon: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: RPTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(RPTheme.accent)
                .frame(width: 28)
            Text(label)
                .font(.system(.body, design: .default))
                .foregroundStyle(RPTheme.textPrimary)
            Spacer()
            Toggle("", isOn: isOn)
                .tint(RPTheme.accent)
                .labelsHidden()
        }
        .padding(RPTheme.Spacing.md)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 14))
    }
}
