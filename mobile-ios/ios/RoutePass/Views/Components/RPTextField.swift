import SwiftUI

/// Champ de saisie ROUTEPASS — fond dark2, bordure or au focus, icône or à gauche.
struct RPTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var isSecure: Bool = false
    var contentType: UITextContentType? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(isFocused ? RPTheme.gold : RPTheme.gray)
                .frame(width: 18)

            if isSecure {
                SecureField(text: $text) {
                    Text(placeholder).foregroundStyle(RPTheme.gray.opacity(0.6))
                }
                .font(RPFont.body(15))
                .foregroundStyle(RPTheme.white)
                .focused($isFocused)
                .textInputAutocapitalization(autocapitalization)
                .textContentType(contentType)
            } else {
                TextField(text: $text) {
                    Text(placeholder).foregroundStyle(RPTheme.gray.opacity(0.6))
                }
                .font(RPFont.body(15))
                .foregroundStyle(RPTheme.white)
                .keyboardType(keyboardType)
                .focused($isFocused)
                .textInputAutocapitalization(autocapitalization)
                .textContentType(contentType)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: RPTheme.inputRadius)
                .fill(RPTheme.dark2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: RPTheme.inputRadius)
                .stroke(isFocused ? RPTheme.gold.opacity(0.6) : RPTheme.border, lineWidth: 1)
        )
        .animation(.easeOut(duration: 0.2), value: isFocused)
    }
}
