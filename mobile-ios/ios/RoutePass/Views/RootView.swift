import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            switch appState.currentFlow {
            case .splash:
                SplashView {
                    appState.completeSplash()
                }
                .transition(.opacity)

            case .onboarding:
                OnboardingView { role in
                    appState.selectedRole = role
                    appState.completeOnboarding()
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            case .auth:
                AuthView(
                    selectedRole: appState.selectedRole ?? .client,
                    onAuthenticated: { email in
                        appState.completeAuth(
                            email: email,
                            role: appState.selectedRole ?? .client
                        )
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            case .main:
                ContentView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: appState.currentFlow)
    }
}
