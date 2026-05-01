import SwiftUI

struct MapMarkerView: View {
    let item: MapItem
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(item.category.markerColor)
                    .frame(width: isSelected ? 48 : 38, height: isSelected ? 48 : 38)
                    .shadow(color: item.category.markerColor.opacity(0.4), radius: isSelected ? 8 : 4, y: 2)

                Image(systemName: item.category.icon)
                    .font(.system(size: isSelected ? 20 : 16, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Triangle()
                .fill(item.category.markerColor)
                .frame(width: 12, height: 8)
                .offset(y: -1)
        }
        .scaleEffect(isSelected ? 1.15 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct Triangle: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
