import SwiftUI

@Observable
final class AppState {
    var currentFlow: AppFlow = .splash
    var isAuthenticated: Bool = false
    var hasCompletedOnboarding: Bool = false
    var selectedRole: UserRole?
    var userEmail: String = ""
    var userPhone: String = ""
    var useFaceID: Bool = false

    enum AppFlow: Equatable {
        case splash
        case onboarding
        case auth
        case main
    }

    func completeSplash() {
        if hasCompletedOnboarding && isAuthenticated {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                currentFlow = .main
            }
        } else if hasCompletedOnboarding {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                currentFlow = .auth
            }
        } else {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                currentFlow = .onboarding
            }
        }
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            currentFlow = .auth
        }
    }

    func completeAuth(email: String, role: UserRole) {
        userEmail = email
        selectedRole = role
        isAuthenticated = true
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            currentFlow = .main
        }
    }

    func signOut() {
        isAuthenticated = false
        selectedRole = nil
        userEmail = ""
        userPhone = ""
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            currentFlow = .auth
        }
    }
}
