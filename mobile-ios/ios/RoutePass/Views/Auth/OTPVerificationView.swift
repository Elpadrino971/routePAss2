import SwiftUI

struct OTPVerificationView: View {
    @Environment(\.dismiss) private var dismiss

    let contactInfo: String
    let isPhone: Bool
    let onVerified: () -> Void

    @State private var otpCode: String = ""
    @State private var appeared: Bool = false
    @State private var isVerifying: Bool = false
    @State private var resendCountdown: Int = 30
    @State private var hapticTrigger: Int = 0
    @FocusState private var isCodeFocused: Bool

    private let codeLength = 6

    var body: some View {
        ZStack {
            RPTheme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(RPTheme.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                }
                .padding(.horizontal, RPTheme.Spacing.md)

                Spacer()

                VStack(spacing: RPTheme.Spacing.xl) {
                    VStack(spacing: RPTheme.Spacing.sm) {
                        Image(systemName: isPhone ? "iphone.badge.play" : "envelope.open.fill")
                            .font(.system(size: 48, weight: .light))
                            .foregroundStyle(RPTheme.accent)
                            .opacity(appeared ? 1 : 0)
                            .scaleEffect(appeared ? 1 : 0.7)

                        Text("Vérification")
                            .font(.system(size: 28, weight: .bold, design: .default))
                            .foregroundStyle(RPTheme.textPrimary)

                        Text("Code envoyé à \(contactInfo)")
                            .font(.system(size: 15, weight: .regular, design: .default))
                            .foregroundStyle(RPTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 15)

                    codeInputSection

                    Button {
                        verifyCode()
                    } label: {
                        if isVerifying {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Vérifier")
                        }
                    }
                    .buttonStyle(RPPrimaryButtonStyle())
                    .disabled(otpCode.count < codeLength || isVerifying)
                    .opacity(otpCode.count < codeLength ? 0.6 : 1)
                    .padding(.horizontal, RPTheme.Spacing.lg)

                    resendSection
                }
                .opacity(appeared ? 1 : 0)

                Spacer()
                Spacer()
            }
        }
        .sensoryFeedback(.selection, trigger: hapticTrigger)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
            isCodeFocused = true
            startResendTimer()
        }
    }

    private var codeInputSection: some View {
        VStack(spacing: RPTheme.Spacing.md) {
            HStack(spacing: 12) {
                ForEach(0..<codeLength, id: \.self) { index in
                    let char = characterAt(index)
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(RPTheme.backgroundSecondary)
                            .frame(width: 48, height: 56)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        index == otpCode.count ? RPTheme.accent : .clear,
                                        lineWidth: 2
                                    )
                            )

                        if let char {
                            Text(String(char))
                                .font(.system(size: 24, weight: .bold, design: .default))
                                .foregroundStyle(RPTheme.textPrimary)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: otpCode)
                }
            }

            TextField("", text: $otpCode)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isCodeFocused)
                .frame(width: 0, height: 0)
                .opacity(0)
                .onChange(of: otpCode) { _, newValue in
                    let filtered = String(newValue.prefix(codeLength).filter { $0.isNumber })
                    if filtered != newValue {
                        otpCode = filtered
                    }
                    if filtered.count == codeLength {
                        hapticTrigger += 1
                    }
                }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isCodeFocused = true
        }
    }

    private var resendSection: some View {
        Group {
            if resendCountdown > 0 {
                Text("Renvoyer le code dans \(resendCountdown)s")
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
            } else {
                Button {
                    resendCountdown = 30
                    startResendTimer()
                    hapticTrigger += 1
                } label: {
                    Text("Renvoyer le code")
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundStyle(RPTheme.accent)
                }
            }
        }
    }

    private func characterAt(_ index: Int) -> Character? {
        guard index < otpCode.count else { return nil }
        return otpCode[otpCode.index(otpCode.startIndex, offsetBy: index)]
    }

    private func verifyCode() {
        isVerifying = true
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            isVerifying = false
            onVerified()
        }
    }

    private func startResendTimer() {
        Task {
            while resendCountdown > 0 {
                try? await Task.sleep(for: .seconds(1))
                resendCountdown -= 1
            }
        }
    }
}
