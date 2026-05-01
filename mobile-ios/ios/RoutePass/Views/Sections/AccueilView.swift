import SwiftUI

struct AccueilView: View {
    @State private var isLoading: Bool = true
    @State private var appeared: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                featuredSection
                recentSection
            }
            .padding(.bottom, 80)
        }
        .scrollIndicators(.hidden)
        .task {
            try? await Task.sleep(for: .seconds(1.2))
            withAnimation(.spring(response: 0.4)) {
                isLoading = false
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: RPTheme.Spacing.xs) {
                    Text("Bonjour, Alex")
                        .font(.system(.largeTitle, design: .default, weight: .bold))
                        .foregroundStyle(RPTheme.textPrimary)

                    Text("Que recherchez-vous aujourd'hui ?")
                        .font(.system(.body, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                }

                Spacer()

                Circle()
                    .fill(RPTheme.accent.opacity(0.15))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(RPTheme.accent)
                    }
            }
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .padding(.top, RPTheme.Spacing.lg)
        .padding(.bottom, RPTheme.Spacing.md)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.sm) {
            HStack {
                Text("En vedette")
                    .font(.system(.title3, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Spacer()

                Button("Voir tout") {}
                    .buttonStyle(RPGhostButtonStyle())
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
            }
            .padding(.horizontal, RPTheme.Spacing.md)

            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(MockData.featuredItems) { item in
                        RPFeaturedCard(item: item)
                    }
                }
            }
            .contentMargins(.horizontal, 16)
            .scrollIndicators(.hidden)
        }
        .padding(.bottom, RPTheme.Spacing.lg)
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.sm) {
            HStack {
                Text("Récemment consultés")
                    .font(.system(.title3, design: .default, weight: .bold))
                    .foregroundStyle(RPTheme.textPrimary)

                Spacer()
            }
            .padding(.horizontal, RPTheme.Spacing.md)

            VStack(spacing: RPTheme.Spacing.md) {
                if isLoading {
                    ForEach(0..<3, id: \.self) { _ in
                        ShimmerCardView()
                    }
                } else {
                    ForEach(Array(MockData.transportItems.prefix(3))) { item in
                        RPCard(item: item)
                            .sensoryFeedback(.impact(flexibility: .soft), trigger: item.id)
                    }
                }
            }
            .padding(.horizontal, RPTheme.Spacing.md)

            Button("Explorer tout") {}
                .buttonStyle(RPPrimaryButtonStyle())
                .padding(.horizontal, RPTheme.Spacing.md)
                .padding(.top, RPTheme.Spacing.sm)
        }
    }
}
