import SwiftUI

struct ValidationRow: View {
    let validation: PendingValidation
    @State private var isValidated: Bool = false
    @State private var isRejected: Bool = false

    private var timeText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: validation.submittedDate, relativeTo: Date())
    }

    var body: some View {
        if !isValidated && !isRejected {
            HStack(spacing: 12) {
                Image(systemName: validation.avatarSystemName)
                    .font(.system(size: 36))
                    .foregroundStyle(RPTheme.textSecondary.opacity(0.4))

                VStack(alignment: .leading, spacing: 3) {
                    Text(validation.name)
                        .font(.system(.subheadline, design: .default, weight: .semibold))
                        .foregroundStyle(RPTheme.textPrimary)

                    Text(validation.documentType)
                        .font(.system(.caption, design: .default))
                        .foregroundStyle(RPTheme.textSecondary)

                    HStack(spacing: 4) {
                        Text(validation.role)
                            .font(.system(.caption2, design: .default))
                            .foregroundStyle(RPTheme.accent)
                        Text("·")
                            .foregroundStyle(RPTheme.textSecondary)
                        Text(timeText)
                            .font(.system(.caption2, design: .default))
                            .foregroundStyle(RPTheme.textSecondary)
                    }
                }

                Spacer()

                HStack(spacing: 8) {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            isRejected = true
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.red)
                            .frame(width: 36, height: 36)
                            .background(.red.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.5), trigger: isRejected)

                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            isValidated = true
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.green)
                            .frame(width: 36, height: 36)
                            .background(.green.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .sensoryFeedback(.success, trigger: isValidated)
                }
            }
            .padding(.horizontal, RPTheme.Spacing.md)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemBackground))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(validation.name), \(validation.documentType), \(validation.role)")
            .accessibilityHint("Actions disponibles : valider ou rejeter")
        }
    }
}
