import SwiftUI

/// Sélection du rôle ROUTEPASS — sheet sombre, cards or sur sélection.
struct RoleSelectionView: View {
    let onRoleSelected: (UserRole) -> Void

    @State private var appeared: Bool = false
    @State private var selectedRole: UserRole?
    @State private var hapticTrigger: Int = 0

    var body: some View {
        ZStack {
            RPTheme.dark.ignoresSafeArea()

            VStack(spacing: 18) {
                VStack(spacing: 8) {
                    Text("PROFIL").rpKicker()

                    Text("Qui êtes-vous ?")
                        .font(RPFont.display(26))
                        .foregroundStyle(RPTheme.white)

                    Text("Choisissez votre profil pour personnaliser votre expérience.")
                        .font(RPFont.body(13))
                        .foregroundStyle(RPTheme.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, RPTheme.Spacing.lg)
                }
                .padding(.top, 24)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(Array(UserRole.allCases.enumerated()), id: \.element.id) { index, role in
                            roleCard(role: role, index: index)
                        }
                    }
                    .padding(.horizontal, RPTheme.Spacing.lg)
                }
                .scrollIndicators(.hidden)

                if selectedRole != nil {
                    Button("Continuer") {
                        if let r = selectedRole { onRoleSelected(r) }
                    }
                    .buttonStyle(RPPrimaryButtonStyle(size: .lg))
                    .padding(.horizontal, RPTheme.Spacing.lg)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .preferredColorScheme(.dark)
        .sensoryFeedback(.selection, trigger: hapticTrigger)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
    }

    private func roleCard(role: UserRole, index: Int) -> some View {
        let isSelected = selectedRole == role
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedRole = role
            }
            hapticTrigger += 1
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isSelected ? AnyShapeStyle(RPTheme.goldGradient) : AnyShapeStyle(RPTheme.dark2))
                        .frame(width: 50, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(isSelected ? Color.clear : RPTheme.border, lineWidth: 1)
                        )

                    Image(systemName: role.systemIcon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(isSelected ? RPTheme.black : RPTheme.gold)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(role.title)
                        .font(RPFont.body(15, weight: .semibold))
                        .foregroundStyle(RPTheme.white)

                    Text(role.subtitle)
                        .font(RPFont.body(12))
                        .foregroundStyle(RPTheme.gray)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? RPTheme.gold : RPTheme.border)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: RPTheme.cardRadius)
                    .fill(RPTheme.dark2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: RPTheme.cardRadius)
                    .stroke(isSelected ? RPTheme.gold.opacity(0.7) : RPTheme.border, lineWidth: 1)
            )
            .scaleEffect(appeared ? 1 : 0.96)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.08), value: appeared)
        }
        .buttonStyle(.plain)
    }
}
