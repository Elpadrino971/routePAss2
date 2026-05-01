import SwiftUI

struct RevenueChartView: View {
    let data: [RevenuePoint]
    @State private var appeared: Bool = false

    private var maxAmount: Double {
        data.map(\.amount).max() ?? 1
    }

    private var normalizedPoints: [CGFloat] {
        data.map { CGFloat($0.amount / maxAmount) }
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let stepX = width / CGFloat(max(normalizedPoints.count - 1, 1))

            ZStack {
                LinearGradient(
                    colors: [RPTheme.accent.opacity(0.2), RPTheme.accent.opacity(0.02)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(
                    AreaShape(points: normalizedPoints, stepX: stepX, height: height)
                )
                .opacity(appeared ? 1 : 0)

                LineShape(points: normalizedPoints, stepX: stepX, height: height)
                    .trim(from: 0, to: appeared ? 1 : 0)
                    .stroke(
                        RPTheme.accent,
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                    )
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.4)) {
                appeared = true
            }
        }
    }
}

private struct LineShape: Shape {
    let points: [CGFloat]
    let stepX: CGFloat
    let height: CGFloat

    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }
        let padding: CGFloat = 8
        let usableHeight = height - padding * 2

        for (index, value) in points.enumerated() {
            let x = CGFloat(index) * stepX
            let y = padding + usableHeight * (1 - value)
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                let prev = points[index - 1]
                let prevX = CGFloat(index - 1) * stepX
                let prevY = padding + usableHeight * (1 - prev)
                let midX = (prevX + x) / 2
                path.addCurve(
                    to: CGPoint(x: x, y: y),
                    control1: CGPoint(x: midX, y: prevY),
                    control2: CGPoint(x: midX, y: y)
                )
            }
        }
        return path
    }
}

private struct AreaShape: Shape {
    let points: [CGFloat]
    let stepX: CGFloat
    let height: CGFloat

    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }
        let padding: CGFloat = 8
        let usableHeight = height - padding * 2

        path.move(to: CGPoint(x: 0, y: height))

        for (index, value) in points.enumerated() {
            let x = CGFloat(index) * stepX
            let y = padding + usableHeight * (1 - value)
            if index == 0 {
                path.addLine(to: CGPoint(x: x, y: y))
            } else {
                let prev = points[index - 1]
                let prevX = CGFloat(index - 1) * stepX
                let prevY = padding + usableHeight * (1 - prev)
                let midX = (prevX + x) / 2
                path.addCurve(
                    to: CGPoint(x: x, y: y),
                    control1: CGPoint(x: midX, y: prevY),
                    control2: CGPoint(x: midX, y: y)
                )
            }
        }

        let lastX = CGFloat(points.count - 1) * stepX
        path.addLine(to: CGPoint(x: lastX, y: height))
        path.closeSubpath()
        return path
    }
}
