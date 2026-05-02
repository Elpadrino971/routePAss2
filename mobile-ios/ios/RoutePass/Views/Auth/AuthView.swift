import SwiftUI
import AuthenticationServices

/// Auth ROUTEPASS — fond noir luxe, monogramme R or, champs dark luxury,
/// bouton or "Se connecter" / "S'inscrire", Sign in with Apple en blanc.
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
            RPTheme.black.ignoresSafeArea()

            // Halo doré subtil en haut
            VStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [RPTheme.gold.opacity(0.12), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 360, height: 360)
                    .offset(y: -120)
                Spacer()
            }
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, 56)
                        .padding(.bottom, 32)

                    formSection
                        .padding(.bottom, 22)

                    dividerSection
                        .padding(.bottom, 18)

                    appleSignInSection
                        .padding(.bottom, 28)

                    toggleSection
                }
                .padding(.horizontal, RPTheme.Spacing.lg)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
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

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 14) {
            Text("R")
                .font(RPFont.display(72))
                .foregroundStyle(RPTheme.goldGradient)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.85)

            Text("ROUTEPASS")
                .font(.system(size: 12, weight: .semibold))
                .tracking(6)
                .foregroundStyle(RPTheme.gold)

            VStack(spacing: 6) {
                Text(isLogin ? "Bon retour" : "Créer un compte")
                    .font(RPFont.display(28))
                    .foregroundStyle(RPTheme.white)

                Text(isLogin
                    ? "Connectez-vous pour continuer."
                    : "Rejoignez ROUTEPASS en quelques secondes.")
                    .font(RPFont.body(13))
                    .foregroundStyle(RPTheme.gray)
                    .multilineTextAlignment(.center)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
        }
    }

    private var formSection: some View {
        VStack(spacing: 12) {
            RPTextField(
                icon: "envelope.fill",
                placeholder: "Email",
                text: $email,
                keyboardType: .emailAddress,
                autocapitalization: .never,
                contentType: .emailAddress
            )

            RPTextField(
                icon: "phone.fill",
                placeholder: "Téléphone (optionnel)",
                text: $phone,
                keyboardType: .phonePad,
                contentType: .telephoneNumber
            )

            Button {
                hapticTrigger += 1
                showOTP = true
            } label: {
                Text(isLogin ? "Se connecter" : "S'inscrire")
            }
            .buttonStyle(RPPrimaryButtonStyle(size: .lg))
            .disabled(email.isEmpty)
            .opacity(email.isEmpty ? 0.5 : 1)
            .padding(.top, 6)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.15), value: appeared)
    }

    private var dividerSection: some View {
        HStack(spacing: 12) {
            line
            Text("ou")
                .font(RPFont.body(11, weight: .medium))
                .foregroundStyle(RPTheme.gray)
            line
        }
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: appeared)
    }

    private var line: some View {
        LinearGradient(
            colors: [RPTheme.gold.opacity(0), RPTheme.gold.opacity(0.4), RPTheme.gold.opacity(0)],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 1)
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
        .signInWithAppleButtonStyle(.white)
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
                    .foregroundStyle(RPTheme.gray)
                Text(isLogin ? "S'inscrire" : "Se connecter")
                    .foregroundStyle(RPTheme.gold)
                    .fontWeight(.semibold)
            }
            .font(RPFont.body(13))
        }
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3), value: appeared)
    }
}
