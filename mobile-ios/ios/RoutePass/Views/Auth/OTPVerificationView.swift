import SwiftUI

/// Écran de vérification OTP — 6 cases mono dark luxury, focus or, vérif animée.
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
            RPTheme.black.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                Spacer(minLength: 24)

                VStack(spacing: 24) {
                    headerBlock
                    codeInputSection
                    verifyButton
                    resendSection
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)

                Spacer()
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .sensoryFeedback(.selection, trigger: hapticTrigger)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
            isCodeFocused = true
            startResendTimer()
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(RPTheme.white)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle().fill(RPTheme.dark)
                            .overlay(Circle().stroke(RPTheme.border))
                    )
            }
            Spacer()
        }
        .padding(.horizontal, RPTheme.Spacing.lg)
        .padding(.top, 8)
    }

    private var headerBlock: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(RPTheme.dark)
                    .frame(width: 76, height: 76)
                    .overlay(Circle().stroke(RPTheme.gold.opacity(0.4), lineWidth: 1))

                Image(systemName: isPhone ? "iphone.gen3.radiowaves.left.and.right" : "envelope.open.fill")
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(RPTheme.gold)
            }

            VStack(spacing: 6) {
                Text("VÉRIFICATION").rpKicker()

                Text("Entrez votre code")
                    .font(RPFont.display(24))
                    .foregroundStyle(RPTheme.white)

                Text("Code envoyé à \(contactInfo)")
                    .font(RPFont.body(13))
                    .foregroundStyle(RPTheme.gray)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Code input

    private var codeInputSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                ForEach(0..<codeLength, id: \.self) { index in
                    let char = characterAt(index)
                    let isCurrent = index == otpCode.count
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(RPTheme.dark2)
                            .frame(width: 44, height: 54)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        char != nil ? RPTheme.gold.opacity(0.7)
                                            : (isCurrent ? RPTheme.gold : RPTheme.border),
                                        lineWidth: isCurrent || char != nil ? 1.4 : 1
                                    )
                            )

                        if let char {
                            Text(String(char))
                                .font(RPFont.mono(24, weight: .semibold))
                                .foregroundStyle(RPTheme.white)
                                .transition(.scale.combined(with: .opacity))
                        } else if isCurrent {
                            CursorBlink()
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
                    if filtered != newValue { otpCode = filtered }
                    if filtered.count == codeLength { hapticTrigger += 1 }
                }
        }
        .contentShape(Rectangle())
        .onTapGesture { isCodeFocused = true }
    }

    private var verifyButton: some View {
        Button {
            verifyCode()
        } label: {
            if isVerifying {
                ProgressView().tint(RPTheme.black)
            } else {
                Text("Vérifier")
            }
        }
        .buttonStyle(RPPrimaryButtonStyle(size: .lg))
        .disabled(otpCode.count < codeLength || isVerifying)
        .opacity(otpCode.count < codeLength ? 0.5 : 1)
        .padding(.horizontal, RPTheme.Spacing.lg)
    }

    private var resendSection: some View {
        Group {
            if resendCountdown > 0 {
                Text("Renvoyer le code dans \(resendCountdown)s")
                    .font(RPFont.body(13))
                    .foregroundStyle(RPTheme.gray)
            } else {
                Button {
                    resendCountdown = 30
                    startResendTimer()
                    hapticTrigger += 1
                } label: {
                    Text("Renvoyer le code")
                        .font(RPFont.body(13, weight: .semibold))
                        .foregroundStyle(RPTheme.gold)
                }
            }
        }
    }

    // MARK: - Helpers

    private func characterAt(_ index: Int) -> Character? {
        guard index < otpCode.count else { return nil }
        return otpCode[otpCode.index(otpCode.startIndex, offsetBy: index)]
    }

    private func verifyCode() {
        isVerifying = true
        Task {
            try? await Task.sleep(for: .seconds(1.0))
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

/// Curseur clignotant or pour la case en cours de saisie.
private struct CursorBlink: View {
    @State private var visible = true
    var body: some View {
        Rectangle()
            .fill(RPTheme.gold)
            .frame(width: 2, height: 22)
            .opacity(visible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                    visible = false
                }
            }
    }
}
