import SwiftUI

struct RPBadge: View {
    let status: RPStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.caption2)
            Text(status.rawValue)
                .font(.system(.caption, design: .rounded, weight: .semibold))
        }
        .foregroundStyle(status.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(status.color.opacity(0.12))
        .clipShape(Capsule())
    }
}
