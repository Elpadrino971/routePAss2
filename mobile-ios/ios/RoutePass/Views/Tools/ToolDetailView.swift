import SwiftUI

struct ToolDetailView: View {
    let tool: ToolItem
    @Binding var selectedPricingUnit: PricingUnit
    @Binding var addInsurance: Bool
    let computedTotal: String
    let insuranceAmount: String
    let onBook: () -> Void
    let onDismiss: () -> Void

    @State private var currentGalleryIndex: Int = 0
    @State private var selectedMonth: Date = Date()
    @State private var contentAppeared: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    gallerySection
                    contentSection
                }
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
            .overlay(alignment: .bottom) {
                bookingBar
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { onDismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(RPTheme.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }

    private var gallerySection: some View {
        TabView(selection: $currentGalleryIndex) {
            ForEach(Array(tool.gallery.enumerated()), id: \.offset) { index, url in
                RPImage(url: url, fallback: tool.icon)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: 280)
        .overlay(alignment: .topTrailing) {
            RPBadge(status: tool.status)
                .padding(RPTheme.Spacing.md)
        }
        .overlay(alignment: .topLeading) {
            HStack(spacing: 4) {
                Image(systemName: tool.condition.icon)
                    .font(.caption2)
                Text(tool.condition.rawValue)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(tool.condition.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(tool.condition.color.opacity(0.12))
            .clipShape(Capsule())
            .padding(RPTheme.Spacing.md)
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.lg) {
            headerSection
            Divider().padding(.horizontal, RPTheme.Spacing.md)
            specsSection
            Divider().padding(.horizontal, RPTheme.Spacing.md)
            descriptionSection
            featuresSection
            Divider().padding(.horizontal, RPTheme.Spacing.md)
            pricingSection
            Divider().padding(.horizontal, RPTheme.Spacing.md)
            depositSection
            Divider().padding(.horizontal, RPTheme.Spacing.md)
            insuranceSection
            if tool.deliveryAvailable {
                Divider().padding(.horizontal, RPTheme.Spacing.md)
                deliverySection
            }
            if tool.accessMethod != .livraison {
                Divider().padding(.horizontal, RPTheme.Spacing.md)
                accessSection
            }
            Divider().padding(.horizontal, RPTheme.Spacing.md)
            calendarSection
        }
        .opacity(contentAppeared ? 1 : 0)
        .offset(y: contentAppeared ? 0 : 16)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85).delay(0.15)) {
                contentAppeared = true
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.sm) {
            Text(tool.name)
                .font(.system(.title2, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)

            Text("\(tool.brand) · \(tool.model) · \(String(tool.year))")
                .font(.system(.subheadline, design: .default))
                .foregroundStyle(RPTheme.textSecondary)

            HStack(spacing: RPTheme.Spacing.sm) {
                ownerBadge
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Text(String(format: "%.1f", tool.rating))
                        .font(.system(.subheadline, design: .default, weight: .semibold))
                    Text("(\(tool.reviewCount) avis)")
                        .font(.system(.caption, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                }
            }
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .padding(.top, RPTheme.Spacing.lg)
    }

    private var ownerBadge: some View {
        HStack(spacing: RPTheme.Spacing.sm) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(RPTheme.accent.opacity(0.6))
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(tool.ownerName)
                        .font(.system(.subheadline, design: .default, weight: .medium))
                        .foregroundStyle(RPTheme.textPrimary)
                    if tool.ownerVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption2)
                            .foregroundStyle(RPTheme.accent)
                    }
                }
                Text("Propriétaire")
                    .font(.system(.caption2, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }
        }
    }

    private var specsSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Spécifications")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: RPTheme.Spacing.sm) {
                specCard(icon: "scalemass.fill", label: "Poids", value: tool.weight)
                specCard(icon: "ruler.fill", label: "Dimensions", value: tool.dimensions)
                specCard(icon: tool.skillLevel.icon, label: "Niveau requis", value: tool.skillLevel.rawValue, color: tool.skillLevel.color)
                specCard(icon: tool.consumablesIncluded ? "checkmark.circle.fill" : "xmark.circle.fill",
                         label: "Consommables", value: tool.consumablesIncluded ? "Inclus" : "Non inclus",
                         color: tool.consumablesIncluded ? .green : RPTheme.textSecondary)
            }

            if tool.hasManual {
                HStack(spacing: RPTheme.Spacing.sm) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(RPTheme.accent)
                    Text("Manuel d'utilisation disponible")
                        .font(.system(.caption, design: .default, weight: .medium))
                        .foregroundStyle(RPTheme.textPrimary)
                    Spacer()
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(RPTheme.accent)
                }
                .padding(12)
                .background(RPTheme.accent.opacity(0.06))
                .clipShape(.rect(cornerRadius: 12))
            }

            if let detail = tool.consumablesDetail {
                HStack(spacing: RPTheme.Spacing.sm) {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.green)
                    Text(detail)
                        .font(.system(.caption, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                }
            }
        }
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private func specCard(icon: String, label: String, value: String, color: Color = RPTheme.accent) -> some View {
        HStack(spacing: RPTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.1))
                .clipShape(.rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(.caption2, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
                Text(value)
                    .font(.system(.caption, design: .default, weight: .semibold))
                    .foregroundStyle(RPTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(Color(.tertiarySystemFill))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.sm) {
            Text("Description")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)
            Text(tool.description)
                .font(.system(.subheadline, design: .default))
                .foregroundStyle(RPTheme.textSecondary)
                .lineSpacing(4)
        }
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private var featuresSection: some View {
        ScrollView(.horizontal) {
            HStack(spacing: RPTheme.Spacing.sm) {
                ForEach(tool.features, id: \.self) { feature in
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(RPTheme.accent)
                        Text(feature)
                            .font(.system(.caption, design: .default, weight: .medium))
                            .foregroundStyle(RPTheme.textPrimary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(RPTheme.accent.opacity(0.08))
                    .clipShape(Capsule())
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .scrollIndicators(.hidden)
    }

    private var pricingSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Tarifs")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)

            Picker("Durée", selection: $selectedPricingUnit) {
                ForEach(availableUnits) { unit in
                    Text(unit.rawValue).tag(unit)
                }
            }
            .pickerStyle(.segmented)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(computedTotal)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(RPTheme.accent)
                Text("/ \(selectedPricingUnit.rawValue.lowercased())")
                    .font(.system(.subheadline, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }

            if selectedPricingUnit == .week {
                discountBadge(text: "−10% tarif dégressif semaine")
            } else if selectedPricingUnit == .month {
                discountBadge(text: "−20% tarif dégressif mois")
            }
        }
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private func discountBadge(text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "tag.fill")
                .font(.caption2)
                .foregroundStyle(.green)
            Text(text)
                .font(.system(.caption, design: .default, weight: .medium))
                .foregroundStyle(.green)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.green.opacity(0.1))
        .clipShape(Capsule())
    }

    private var availableUnits: [PricingUnit] {
        if tool.pricePerHour != nil {
            return PricingUnit.allCases
        }
        return [.day, .week, .month]
    }

    private var depositSection: some View {
        HStack(spacing: RPTheme.Spacing.md) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 24))
                .foregroundStyle(RPTheme.accent.opacity(0.7))
                .frame(width: 44, height: 44)
                .background(RPTheme.accent.opacity(0.08))
                .clipShape(.rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text("Caution : \(tool.deposit)")
                    .font(.system(.subheadline, design: .default, weight: .semibold))
                    .foregroundStyle(RPTheme.textPrimary)
                Text("Stripe Hold activé — libéré à la restitution confirmée")
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(RPTheme.Spacing.md)
        .background(Color(.tertiarySystemFill))
        .clipShape(.rect(cornerRadius: 14))
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private var insuranceSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Assurance")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)

            HStack(spacing: RPTheme.Spacing.md) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 20))
                    .foregroundStyle(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Assurance casse")
                        .font(.system(.subheadline, design: .default, weight: .semibold))
                        .foregroundStyle(RPTheme.textPrimary)
                    Text("+\(Int(tool.insuranceRate * 100))% du montant · \(insuranceAmount)")
                        .font(.system(.caption, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                }

                Spacer(minLength: 0)

                Toggle("", isOn: $addInsurance)
                    .tint(RPTheme.accent)
                    .labelsHidden()
            }
            .padding(RPTheme.Spacing.md)
            .background(Color(.tertiarySystemFill))
            .clipShape(.rect(cornerRadius: 14))
        }
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private var deliverySection: some View {
        HStack(spacing: RPTheme.Spacing.md) {
            Image(systemName: "shippingbox.and.arrow.backward.fill")
                .font(.system(size: 20))
                .foregroundStyle(.purple)
                .frame(width: 40, height: 40)
                .background(Color.purple.opacity(0.1))
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text("Livraison disponible")
                    .font(.system(.subheadline, design: .default, weight: .semibold))
                    .foregroundStyle(RPTheme.textPrimary)
                if let price = tool.deliveryPrice {
                    Text("Tarif livraison : \(price)")
                        .font(.system(.caption, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(RPTheme.Spacing.md)
        .background(Color(.tertiarySystemFill))
        .clipShape(.rect(cornerRadius: 14))
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private var accessSection: some View {
        HStack(spacing: RPTheme.Spacing.md) {
            Image(systemName: tool.accessMethod == .qrAccess ? "qrcode" : "hand.raised.fill")
                .font(.system(size: 20))
                .foregroundStyle(RPTheme.accent)
                .frame(width: 40, height: 40)
                .background(RPTheme.accent.opacity(0.1))
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text("Mode d'accès : \(tool.accessMethod.rawValue)")
                    .font(.system(.subheadline, design: .default, weight: .semibold))
                    .foregroundStyle(RPTheme.textPrimary)
                Text("Adresse exacte déverrouillée après paiement")
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(RPTheme.Spacing.md)
        .background(Color(.tertiarySystemFill))
        .clipShape(.rect(cornerRadius: 14))
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.md) {
            Text("Disponibilité")
                .font(.system(.headline, design: .default, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)
                .padding(.horizontal, RPTheme.Spacing.md)

            CalendarGridView(
                selectedMonth: $selectedMonth,
                status: tool.status,
                occupiedUntil: tool.occupiedUntil
            )
            .padding(.horizontal, RPTheme.Spacing.md)
        }
    }

    private var bookingBar: some View {
        HStack(spacing: RPTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text(computedTotal)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(RPTheme.accent)
                Text("/ \(selectedPricingUnit.rawValue.lowercased())")
                    .font(.system(.caption, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            }

            Spacer()

            Button {
                onBook()
            } label: {
                Text("Réserver")
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, RPTheme.Spacing.xl)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [RPTheme.accent, RPTheme.accentDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: RPTheme.buttonRadius))
            }
            .disabled(tool.status != .disponible)
            .opacity(tool.status == .disponible ? 1 : 0.5)
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .padding(.vertical, RPTheme.Spacing.md)
        .background(.ultraThinMaterial)
    }
}
