import SwiftUI

struct AdminBarChart: View {
    let data: [AdminBarData]
    @State private var appeared: Bool = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(data) { bar in
                VStack(spacing: 6) {
                    Spacer()

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [RPTheme.accent, RPTheme.accent.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: appeared ? CGFloat(bar.value / bar.maxValue) * 120 : 0)

                    Text(bar.label)
                        .font(.system(.caption2, design: .default, weight: .medium))
                        .foregroundStyle(RPTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                appeared = true
            }
        }
    }
}
