import SwiftUI
import UIKit

// MARK: - Text input

public func inputField(_ value: Binding<String>, placeholder: String = "") -> some View {
	TextField(placeholder, text: value)
		.textFieldStyle(.roundedBorder)
}

@ViewBuilder
public func passwordField(_ text: Binding<String>, show: Binding<Bool>, placeholder: String, submitLabel: SubmitLabel = .done) -> some View {
	HStack {
		Group {
			if show.wrappedValue {
				TextField(placeholder, text: text)
			} else {
				SecureField(placeholder, text: text)
			}
		}
		.textInputAutocapitalization(.never)
		.autocorrectionDisabled()
		.submitLabel(submitLabel)

		Button(action: { show.wrappedValue.toggle() }) {
			SwiftUI.Image(systemName: show.wrappedValue ? "eye.slash" : "eye")
				.foregroundColor(.secondary)
		}
	}
	.frame(maxWidth: .infinity)
	.padding(.horizontal, 8)
	.padding(.vertical, 6)
	.background(Color(.systemBackground))
	.overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.systemGray4)))
}

// MARK: - Password conditions

@ViewBuilder
public func passwordConditions(_ password: String) -> some View {
	if !password.isEmpty {
		VStack(alignment: .leading, spacing: 6) {
			passwordConditionRow(String.localize("passwordCondLength"), met: password.count >= 8)
			passwordConditionRow(String.localize("passwordCondUppercase"), met: password.range(of: "[A-Z]", options: .regularExpression) != nil)
			passwordConditionRow(String.localize("passwordCondLowercase"), met: password.range(of: "[a-z]", options: .regularExpression) != nil)
			passwordConditionRow(String.localize("passwordCondNumber"), met: password.range(of: "[0-9]", options: .regularExpression) != nil)
			passwordConditionRow(String.localize("passwordCondSpecial"), met: password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil)
		}
	}
}

private func passwordConditionRow(_ label: String, met: Bool) -> some View {
	HStack(spacing: 6) {
		SwiftUI.Image(systemName: met ? "checkmark" : "xmark")
			.font(.caption)
			.foregroundColor(met ? .green : .red)
		Text(label)
			.font(.caption)
			.foregroundColor(met ? .green : .red)
	}
}

// MARK: - FormContainer

// Wrapper utilisé avec UIHostingController pour forcer SwiftUI à réinitialiser
// les @State quand rootView est remplacé : changer l'id détruit l'ancienne vue
// et en crée une nouvelle avec les bonnes valeurs initiales.
public struct FormContainer<T: View>: View {
	public let id: UUID
	public let content: T
	public var body: some View { content.id(id) }
	public init(id: UUID, content: T) {
		self.id = id
		self.content = content
	}
}