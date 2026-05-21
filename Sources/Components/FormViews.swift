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
	.padding(.horizontal, 8)
	.padding(.vertical, 6)
	.background(Color(.systemBackground))
	.overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(.systemGray4)))
}