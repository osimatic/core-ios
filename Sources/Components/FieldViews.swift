import SwiftUI
import UIKit

// MARK: - NSAttributedLabel

public struct NSAttributedLabel: UIViewRepresentable {
	let attributedString: NSAttributedString

	public init(_ attributedString: NSAttributedString) {
		self.attributedString = attributedString
	}

	public func makeUIView(context: Context) -> UILabel {
		let label = UILabel()
		label.numberOfLines = 0
		label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		label.setContentHuggingPriority(.required, for: .vertical)
		label.setContentCompressionResistancePriority(.required, for: .vertical)
		return label
	}

	public func updateUIView(_ uiView: UILabel, context: Context) {
		uiView.attributedText = attributedString
	}
}

// MARK: - Text helpers

public func fieldLabel(_ text: String) -> some View {
	Text(text)
		.font(.system(size: 14))
		.foregroundColor(.secondary)
}

public func fieldSubLabel(_ text: String) -> some View {
	Text(text)
		.font(.system(size: 13))
		.foregroundColor(.secondary)
}

public func multilineText(_ text: String) -> some View {
	Text(text).font(.system(size: 14)).fixedSize(horizontal: false, vertical: true)
}

public func valueText(_ text: String, color: Color? = nil) -> some View {
	Text(text)
		.font(.system(size: 14, weight: .medium))
		.foregroundColor(color ?? .primary)
}

public func valueText(_ attr: AttributedString) -> some View {
	Text(attr).font(.system(size: 14, weight: .medium))
}

// MARK: - Horizontal fields

public func horizontalField(_ label: String, _ value: String, isSubLabel: Bool = false, color: Color? = nil, labelWidth: CGFloat = 120) -> some View {
	HStack(alignment: .firstTextBaseline, spacing: 8) {
		Group { if isSubLabel { fieldSubLabel(label) } else { fieldLabel(label) } }
			.frame(width: labelWidth, alignment: .trailing)
		valueText(value, color: color)
			.frame(maxWidth: .infinity, alignment: .leading)
	}
}

@ViewBuilder
public func horizontalField<Content: View>(_ label: String, isSubLabel: Bool = false, labelWidth: CGFloat = 120, @ViewBuilder _ content: () -> Content) -> some View {
	HStack(alignment: .firstTextBaseline, spacing: 8) {
		Group { if isSubLabel { fieldSubLabel(label) } else { fieldLabel(label) } }
			.frame(width: labelWidth, alignment: .trailing)
		content()
			.frame(maxWidth: .infinity, alignment: .leading)
	}
}

@ViewBuilder
public func horizontalField(_ label: String, _ ns: NSAttributedString, isSubLabel: Bool = false, labelWidth: CGFloat = 120) -> some View {
	HStack(alignment: .firstTextBaseline, spacing: 8) {
		Group {
            if isSubLabel {
                fieldSubLabel(label)
            }
            else {
                fieldLabel(label)
            }
        }
        .frame(width: labelWidth, alignment: .trailing)
		NSAttributedLabel(ns)
        .frame(maxWidth: .infinity, alignment: .leading)
	}
}

// MARK: - Vertical fields

public func verticalField(_ label: String, _ value: String, isSubLabel: Bool = false) -> some View {
	VStack(alignment: .leading, spacing: 4) {
		if isSubLabel {
            fieldSubLabel(label)
        }
        else {
            fieldLabel(label)
        }
		multilineText(value)
	}
	.frame(maxWidth: .infinity, alignment: .leading)
}

@ViewBuilder
public func verticalField<Content: View>(_ label: String, isSubLabel: Bool = false, @ViewBuilder _ content: () -> Content) -> some View {
	VStack(alignment: .leading, spacing: 4) {
		if !label.isEmpty {
			if isSubLabel { fieldSubLabel(label) } else { fieldLabel(label) }
		}
		content()
	}
	.frame(maxWidth: .infinity, alignment: .leading)
}