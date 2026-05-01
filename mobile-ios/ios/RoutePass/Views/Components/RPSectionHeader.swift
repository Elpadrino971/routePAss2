import SwiftUI

struct RPSectionHeader: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: RPTheme.Spacing.sm) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(RPTheme.accent)
                    .frame(width: 48, height: 48)
                    .background(RPTheme.accent.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.title2, design: .default, weight: .bold))
                        .foregroundStyle(RPTheme.textPrimary)

                    Text(subtitle)
                        .font(.system(.subheadline, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                }
            }
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .padding(.top, RPTheme.Spacing.lg)
        .padding(.bottom, RPTheme.Spacing.sm)
    }
}
