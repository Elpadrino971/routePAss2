import SwiftUI

struct RoleSelectionView: View {
    let onRoleSelected: (UserRole) -> Void

    @State private var appeared: Bool = false
    @State private var selectedRole: UserRole?
    @State private var hapticTrigger: Int = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RPTheme.Spacing.lg) {
                    VStack(spacing: RPTheme.Spacing.sm) {
                        Text("Qui êtes-vous ?")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundStyle(RPTheme.textPrimary)

                        Text("Choisissez votre profil pour personnaliser votre expérience.")
                            .font(.system(size: 15, weight: .regular, design: .default))
                            .foregroundStyle(RPTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, RPTheme.Spacing.sm)

                    VStack(spacing: RPTheme.Spacing.md) {
                        ForEach(Array(UserRole.allCases.enumerated()), id: \.element.id) { index, role in
                            roleCard(role: role, index: index)
                        }
                    }
                    .padding(.horizontal, RPTheme.Spacing.md)

                    if let selected = selectedRole {
                        Button {
                            onRoleSelected(selected)
                        } label: {
                            Text("Continuer")
                        }
                        .buttonStyle(RPPrimaryButtonStyle())
                        .padding(.horizontal, RPTheme.Spacing.md)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.bottom, RPTheme.Spacing.xl)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
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
            HStack(spacing: RPTheme.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(isSelected ? RPTheme.accent.opacity(0.12) : RPTheme.separator)
                        .frame(width: 56, height: 56)

                    Text(role.icon)
                        .font(.system(size: 26))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(role.title)
                        .font(.system(size: 17, weight: .semibold, design: .default))
                        .foregroundStyle(RPTheme.textPrimary)

                    Text(role.subtitle)
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? RPTheme.accent : RPTheme.textSecondary.opacity(0.3))
            }
            .padding(RPTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: RPTheme.cardRadius)
                    .fill(RPTheme.backgroundSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: RPTheme.cardRadius)
                    .stroke(isSelected ? RPTheme.accent : .clear, lineWidth: 2)
            )
            .scaleEffect(appeared ? 1 : 0.95)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.08), value: appeared)
        }
    }
}
