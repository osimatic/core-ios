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

@ViewBuilder
private func checkboxLayout<Content: View>(vertical: Bool, @ViewBuilder content: () -> Content) -> some View {
	if vertical {
		VStack(spacing: 4) { content() }
	} else {
		HStack(spacing: 8) { content() }
	}
}

private func checkboxCore(_ label: String, isChecked: Binding<Bool>, vertical: Bool) -> some View {
	Button { isChecked.wrappedValue.toggle() } label: {
		checkboxLayout(vertical: vertical) {
			SwiftUI.Image(systemName: isChecked.wrappedValue ? "checkmark.square.fill" : "square")
				.foregroundColor(isChecked.wrappedValue ? .accentColor : .secondary)
				.font(.system(size: vertical ? 22 : 20))
			Text(label)
				.font(.system(size: vertical ? 11 : 14))
				.foregroundColor(vertical ? .secondary : .primary)
		}
	}
	.buttonStyle(.plain)
}

public func checkboxField(_ label: String, isChecked: Binding<Bool>) -> some View {
	checkboxCore(label, isChecked: isChecked, vertical: false)
}

public func checkboxFieldVertical(_ label: String, isChecked: Binding<Bool>) -> some View {
	checkboxCore(label, isChecked: isChecked, vertical: true)
}

private func optBinding<T>(_ b: Binding<T>) -> Binding<T?> {
	Binding(get: { b.wrappedValue }, set: { if let v = $0 { b.wrappedValue = v } })
}

private func radioRow<T: Hashable>(_ label: String, tag: T, selection: Binding<T?>) -> some View {
	Button { selection.wrappedValue = tag } label: {
		HStack(spacing: 8) {
			SwiftUI.Image(systemName: selection.wrappedValue == tag ? "largecircle.fill.circle" : "circle")
				.foregroundColor(selection.wrappedValue == tag ? .accentColor : .secondary)
			Text(label).font(.system(size: 14)).foregroundColor(.primary)
		}
	}
	.buttonStyle(.plain)
	.frame(height: 30)
}

@ViewBuilder public func radioButtonsGroup<T: Hashable>(_ opts: [(tag: T, label: String)], selection: Binding<T?>) -> some View {
	ForEach(Array(opts.enumerated()), id: \.offset) { (_, o) in radioRow(o.label, tag: o.tag, selection: selection) }
}
@ViewBuilder public func radioButtonsGroup<T: Hashable>(_ opts: [(tag: T, label: String)], selection: Binding<T>) -> some View {
	radioButtonsGroup(opts, selection: optBinding(selection))
}

public func radioButtonsGroupHStack<T: Hashable>(_ opts: [(tag: T, label: String)], selection: Binding<T?>) -> some View {
	HStack(spacing: 16) { ForEach(Array(opts.enumerated()), id: \.offset) { (_, o) in radioRow(o.label, tag: o.tag, selection: selection) } }.frame(height: 30)
}
public func radioButtonsGroupHStack<T: Hashable>(_ opts: [(tag: T, label: String)], selection: Binding<T>) -> some View {
	radioButtonsGroupHStack(opts, selection: optBinding(selection))
}

public func radioButtonItem<T: Hashable>(_ label: String, tag: T, selection: Binding<T?>) -> some View { radioRow(label, tag: tag, selection: selection) }
public func radioButtonItem<T: Hashable>(_ label: String, tag: T, selection: Binding<T>) -> some View { radioRow(label, tag: tag, selection: optBinding(selection)) }

public func yesNoRadioButtons(_ selection: Binding<Bool>, trueLabel: String = "Yes", falseLabel: String = "No") -> some View {
	radioButtonsGroupHStack([(tag: false, label: falseLabel), (tag: true, label: trueLabel)], selection: selection)
}