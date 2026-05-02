import SwiftUI

/// Section Immobilier — stats en haut + liste des biens en cards horizontales.
/// Utilisée dans Découvrir, donc pas de header propre.
struct ImmobilierView: View {
    @State private var isLoading: Bool = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                statsRow

                Text("Biens premium")
                    .font(RPFont.display(18))
                    .foregroundStyle(RPTheme.white)
                    .padding(.horizontal, RPTheme.Spacing.lg)

                VStack(spacing: 10) {
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
                .padding(.horizontal, RPTheme.Spacing.lg)
            }
            .padding(.top, 4)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background(RPTheme.black.ignoresSafeArea())
        .task {
            try? await Task.sleep(for: .seconds(0.8))
            withAnimation(.spring(response: 0.4)) {
                isLoading = false
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            StatPill(value: "24", label: "Biens",       icon: "house.fill")
            StatPill(value: "8",  label: "Disponibles", icon: "checkmark.seal.fill")
            StatPill(value: "4.8", label: "Note",       icon: "star.fill")
        }
        .padding(.horizontal, RPTheme.Spacing.lg)
    }
}

struct StatPill: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(RPTheme.gold)

            Text(value)
                .font(RPFont.mono(18, weight: .semibold))
                .foregroundStyle(RPTheme.white)

            Text(label)
                .font(RPFont.body(10))
                .foregroundStyle(RPTheme.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RPTheme.dark)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(RPTheme.border, lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: 14))
    }
}
