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

// MARK: - DropDown

public func dropDownField(
	_ options: [DropDownItem],
	selection: Binding<DropDownItem?>,
	placeholder: String,
	listHeight: CGFloat = UIScreen.main.bounds.height * 0.5
) -> some View {
	DropDownView(options: options, selection: selection, placeholder: placeholder)
		.listHeight(listHeight)
		.frame(maxWidth: .infinity)
		.frame(height: 40)
}

// MARK: - Checkbox / Radio

public func checkboxField(_ label: String, isChecked: Binding<Bool>) -> some View {
	HStack {
		CheckboxView(isChecked: isChecked).frame(width: 24, height: 24)
		Text(label).font(.system(size: 14))
	}
}

public func yesNoRadioButtons(_ selection: Binding<Bool>, trueLabel: String = "Yes", falseLabel: String = "No") -> some View {
	HStack(spacing: 12) {
		RadioButtonView(title: falseLabel, tag: false, selection: selection).frame(height: 30)
		RadioButtonView(title: trueLabel, tag: true, selection: selection).frame(height: 30)
	}
}