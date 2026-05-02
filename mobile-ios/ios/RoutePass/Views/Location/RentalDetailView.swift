import SwiftUI

struct RentalDetailView: View {
    let item: RentalItem
    @Binding var selectedPricingUnit: PricingUnit
    let computedTotal: String
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
            ForEach(Array(item.gallery.enumerated()), id: \.offset) { index, url in
                RPImage(url: url, fallback: item.icon)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: 280)
        .overlay(alignment: .topTrailing) {
            RPBadge(status: item.status)
                .padding(RPTheme.Spacing.md)
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.lg) {
            VStack(alignment: .leading, spacing: RPTheme.Spacing.sm) {
                Text(item.name)
                    .font(.system(.title2, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                HStack(spacing: RPTheme.Spacing.sm) {
                    ownerBadge

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Text(String(format: "%.1f", item.rating))
                            .font(.system(.subheadline, design: .default, weight: .semibold))
                        Text("(\(item.reviewCount) avis)")
                            .font(.system(.caption, design: .default))
                            .foregroundStyle(RPTheme.textSecondary)
                    }
                }
            }
            .padding(.horizontal, RPTheme.Spacing.md)
            .padding(.top, RPTheme.Spacing.lg)

            Divider().padding(.horizontal, RPTheme.Spacing.md)

            VStack(alignment: .leading, spacing: RPTheme.Spacing.sm) {
                Text("Description")
                    .font(.system(.headline, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Text(item.description)
                    .font(.system(.subheadline, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
                    .lineSpacing(4)
            }
            .padding(.horizontal, RPTheme.Spacing.md)

            featuresSection

            Divider().padding(.horizontal, RPTheme.Spacing.md)

            pricingSection

            Divider().padding(.horizontal, RPTheme.Spacing.md)

            depositSection

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

    private var ownerBadge: some View {
        HStack(spacing: RPTheme.Spacing.sm) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(RPTheme.accent.opacity(0.6))

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text(item.ownerName)
                        .font(.system(.subheadline, design: .default, weight: .medium))
                        .foregroundStyle(RPTheme.textPrimary)
                    if item.ownerVerified {
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

    private var featuresSection: some View {
        ScrollView(.horizontal) {
            HStack(spacing: RPTheme.Spacing.sm) {
                ForEach(item.features, id: \.self) { feature in
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
        }
        .padding(.horizontal, RPTheme.Spacing.md)
    }

    private var availableUnits: [PricingUnit] {
        if item.pricePerHour != nil {
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
                Text("Caution : \(item.deposit)")
                    .font(.system(.subheadline, design: .default, weight: .semibold))
                    .foregroundStyle(RPTheme.textPrimary)
                Text("Bloqués, libérés automatiquement à la restitution")
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
                status: item.status,
                occupiedUntil: item.occupiedUntil
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
            .disabled(item.status != .disponible)
            .opacity(item.status == .disponible ? 1 : 0.5)
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .padding(.vertical, RPTheme.Spacing.md)
        .background(.ultraThinMaterial)
    }
}
