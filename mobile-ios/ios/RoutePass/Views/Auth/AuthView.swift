import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @State private var isLogin: Bool = true
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var showOTP: Bool = false
    @State private var appeared: Bool = false
    @State private var hapticTrigger: Int = 0

    let selectedRole: UserRole
    let onAuthenticated: (String) -> Void

    var body: some View {
        ZStack {
            RPTheme.backgroundPrimary
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, 60)
                        .padding(.bottom, RPTheme.Spacing.xxl)

                    formSection
                        .padding(.bottom, RPTheme.Spacing.xl)

                    dividerSection
                        .padding(.bottom, RPTheme.Spacing.lg)

                    appleSignInSection
                        .padding(.bottom, RPTheme.Spacing.xl)

                    toggleSection
                }
                .padding(.horizontal, RPTheme.Spacing.lg)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .sensoryFeedback(.selection, trigger: hapticTrigger)
        .fullScreenCover(isPresented: $showOTP) {
            OTPVerificationView(
                contactInfo: phone.isEmpty ? email : phone,
                isPhone: !phone.isEmpty,
                onVerified: {
                    showOTP = false
                    onAuthenticated(email)
                }
            )
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: RPTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(RPTheme.accent.opacity(0.08))
                    .frame(width: 80, height: 80)

                Text("R")
                    .font(.system(size: 40, weight: .bold, design: .default))
                    .foregroundStyle(RPTheme.accent)
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.8)

            VStack(spacing: RPTheme.Spacing.sm) {
                Text(isLogin ? "Bon retour" : "Créer un compte")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundStyle(RPTheme.textPrimary)

                Text(isLogin
                    ? "Connectez-vous pour continuer."
                    : "Rejoignez RoutePass en quelques secondes.")
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundStyle(RPTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 15)
        }
    }

    private var formSection: some View {
        VStack(spacing: RPTheme.Spacing.md) {
            RPTextField(
                icon: "envelope.fill",
                placeholder: "Email",
                text: $email,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )

            RPTextField(
                icon: "phone.fill",
                placeholder: "Téléphone (optionnel)",
                text: $phone,
                keyboardType: .phonePad
            )

            Button {
                hapticTrigger += 1
                showOTP = true
            } label: {
                Text(isLogin ? "Se connecter" : "S'inscrire")
            }
            .buttonStyle(RPPrimaryButtonStyle())
            .disabled(email.isEmpty)
            .opacity(email.isEmpty ? 0.6 : 1)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.15), value: appeared)
    }

    private var dividerSection: some View {
        HStack(spacing: RPTheme.Spacing.md) {
            Rectangle()
                .fill(RPTheme.separator)
                .frame(height: 1)

            Text("ou")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(RPTheme.textSecondary)

            Rectangle()
                .fill(RPTheme.separator)
                .frame(height: 1)
        }
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: appeared)
    }

    private var appleSignInSection: some View {
        SignInWithAppleButton(
            isLogin ? .signIn : .signUp,
            onRequest: { request in
                request.requestedScopes = [.email, .fullName]
            },
            onCompletion: { result in
                switch result {
                case .success:
                    hapticTrigger += 1
                    onAuthenticated(email.isEmpty ? "user@apple.com" : email)
                case .failure:
                    break
                }
            }
        )
        .signInWithAppleButtonStyle(.black)
        .frame(height: 52)
        .clipShape(.rect(cornerRadius: RPTheme.buttonRadius))
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.25), value: appeared)
    }

    private var toggleSection: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isLogin.toggle()
            }
            hapticTrigger += 1
        } label: {
            HStack(spacing: 4) {
                Text(isLogin ? "Pas encore de compte ?" : "Déjà un compte ?")
                    .foregroundStyle(RPTheme.textSecondary)
                Text(isLogin ? "S'inscrire" : "Se connecter")
                    .foregroundStyle(RPTheme.accent)
                    .fontWeight(.semibold)
            }
            .font(.system(size: 14, weight: .regular, design: .default))
        }
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3), value: appeared)
    }
}
