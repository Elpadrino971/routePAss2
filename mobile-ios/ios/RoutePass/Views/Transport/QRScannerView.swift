import SwiftUI

struct QRScannerView: View {
    let onDetected: () -> Void
    let onDismiss: () -> Void

    @State private var cornerScale: CGFloat = 1.0
    @State private var scanLineOffset: CGFloat = -100
    @State private var hapticTrigger: Int = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            #if targetEnvironment(simulator)
            simulatorPlaceholder
            #else
            cameraPlaceholder
            #endif

            scanOverlay

            VStack {
                headerBar
                Spacer()
                instructionLabel
            }
        }
        .sensoryFeedback(.success, trigger: hapticTrigger)
    }

    private var headerBar: some View {
        HStack {
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            Spacer()
            Text("Scanner QR")
                .font(.system(.headline, design: .default, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .padding(.top, RPTheme.Spacing.sm)
    }

    private var scanOverlay: some View {
        ZStack {
            let size: CGFloat = 240
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.3), lineWidth: 1)
                .frame(width: size, height: size)

            cornerGuides(size: size)

            RoundedRectangle(cornerRadius: 2)
                .fill(RPTheme.accent)
                .frame(width: size - 40, height: 2)
                .offset(y: scanLineOffset)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                        scanLineOffset = 100
                    }
                }
        }
    }

    private func cornerGuides(size: CGFloat) -> some View {
        let length: CGFloat = 30
        let offset = size / 2 - 2
        return ZStack {
            CornerShape(corner: .topLeft, length: length)
                .stroke(RPTheme.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: length, height: length)
                .offset(x: -offset, y: -offset)

            CornerShape(corner: .topRight, length: length)
                .stroke(RPTheme.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: length, height: length)
                .offset(x: offset, y: -offset)

            CornerShape(corner: .bottomLeft, length: length)
                .stroke(RPTheme.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: length, height: length)
                .offset(x: -offset, y: offset)

            CornerShape(corner: .bottomRight, length: length)
                .stroke(RPTheme.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: length, height: length)
                .offset(x: offset, y: offset)
        }
        .scaleEffect(cornerScale)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                cornerScale = 1.04
            }
        }
    }

    private var instructionLabel: some View {
        VStack(spacing: RPTheme.Spacing.md) {
            Text("Placez le QR code du prestataire dans le cadre")
                .font(.system(.subheadline, design: .default))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)

            #if targetEnvironment(simulator)
            Button {
                hapticTrigger += 1
                onDetected()
            } label: {
                Text("Simuler un scan")
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, RPTheme.Spacing.lg)
                    .padding(.vertical, 14)
                    .background(RPTheme.accent)
                    .clipShape(.rect(cornerRadius: RPTheme.buttonRadius))
            }
            #endif
        }
        .padding(.bottom, 60)
    }

    private var simulatorPlaceholder: some View {
        VStack(spacing: 20) {
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.3))
            Text("Caméra indisponible en simulateur")
                .font(.system(.footnote, design: .default))
                .foregroundStyle(.white.opacity(0.4))
        }
    }

    private var cameraPlaceholder: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundStyle(.white.opacity(0.3))
            Text("Installez l'app sur votre appareil\npour utiliser la caméra.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
    }
}

nonisolated enum CornerPosition: Sendable {
    case topLeft, topRight, bottomLeft, bottomRight
}

struct CornerShape: Shape {
    let corner: CornerPosition
    let length: CGFloat

    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        switch corner {
        case .topLeft:
            path.move(to: CGPoint(x: 0, y: length))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: length, y: 0))
        case .topRight:
            path.move(to: CGPoint(x: rect.maxX - length, y: 0))
            path.addLine(to: CGPoint(x: rect.maxX, y: 0))
            path.addLine(to: CGPoint(x: rect.maxX, y: length))
        case .bottomLeft:
            path.move(to: CGPoint(x: 0, y: rect.maxY - length))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY))
            path.addLine(to: CGPoint(x: length, y: rect.maxY))
        case .bottomRight:
            path.move(to: CGPoint(x: rect.maxX - length, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - length))
        }
        return path
    }
}
