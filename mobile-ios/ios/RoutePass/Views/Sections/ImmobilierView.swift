import SwiftUI

struct ImmobilierView: View {
    @State private var isLoading: Bool = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                RPSectionHeader(
                    title: "Immobilier",
                    subtitle: "Biens premium à la location",
                    icon: "building.2.fill"
                )

                statsRow

                VStack(spacing: RPTheme.Spacing.md) {
                    if isLoading {
                        ForEach(0..<3, id: \.self) { _ in
                            ShimmerCardView()
                        }
                    } else {
                        ForEach(MockData.immobilierItems) { item in
                            RPCard(item: item)
                        }
                    }
                }
                .padding(.horizontal, RPTheme.Spacing.md)
                .padding(.bottom, 80)
            }
        }
        .scrollIndicators(.hidden)
        .task {
            try? await Task.sleep(for: .seconds(1))
            withAnimation(.spring(response: 0.4)) {
                isLoading = false
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatPill(value: "24", label: "Biens", icon: "house.fill")
            StatPill(value: "8", label: "Disponibles", icon: "checkmark.circle.fill")
            StatPill(value: "4.8", label: "Note", icon: "star.fill")
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .padding(.bottom, RPTheme.Spacing.md)
    }
}

struct StatPill: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: RPTheme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(RPTheme.accent)

            Text(value)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(RPTheme.textPrimary)

            Text(label)
                .font(.system(.caption2, design: .default))
                .foregroundStyle(RPTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 14))
    }
}
