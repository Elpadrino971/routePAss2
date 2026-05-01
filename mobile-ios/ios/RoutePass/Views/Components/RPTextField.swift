import SwiftUI

struct RPTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var isSecure: Bool = false

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: RPTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(isFocused ? RPTheme.accent : RPTheme.textSecondary)
                .frame(width: 20)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .focused($isFocused)
                    .textInputAutocapitalization(autocapitalization)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .keyboardType(keyboardType)
                    .focused($isFocused)
                    .textInputAutocapitalization(autocapitalization)
            }
        }
        .padding(.horizontal, RPTheme.Spacing.md)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: RPTheme.buttonRadius)
                .fill(RPTheme.backgroundSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: RPTheme.buttonRadius)
                .stroke(isFocused ? RPTheme.accent : .clear, lineWidth: 1.5)
        )
        .animation(.easeOut(duration: 0.2), value: isFocused)
    }
}
