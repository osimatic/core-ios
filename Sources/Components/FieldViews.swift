import SwiftUI
import UIKit

// MARK: - Card

public struct Card<Content: View>: View {
	@ViewBuilder public let content: Content
	private let background: Color

	public init(@ViewBuilder _ content: () -> Content, background: Color = Color(.systemBackground)) {
		self.content = content()
		self.background = background
	}

	public init(@ViewBuilder content: () -> Content) {
		self.content = content()
		self.background = Color(.systemBackground)
	}

	public var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			content
		}
		.padding(14)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(background)
		.cornerRadius(10)
		.shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
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

@ViewBuilder
public func nbItemsCard<Content: View>(background: Color = Color(UIColor.systemGray5), @ViewBuilder _ content: () -> Content) -> some View {
	Card({
		VStack(alignment: .center, spacing: 0) {
			content()
		}
		.frame(maxWidth: .infinity)
	}, background: background)
	.padding(.horizontal, 16)
	.padding(.vertical, 4)
}

public func nbItemsText(_ text: String, color: Color = .secondary) -> some View {
	Text(text)
		.font(.system(size: 14))
		.foregroundColor(color)
		.multilineTextAlignment(.center)
		.padding(.vertical, 2)
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
		Group { if isSubLabel { fieldSubLabel(label) } else { fieldLabel(label) } }
			.frame(width: labelWidth, alignment: .trailing)
		Group {
			if let attr = try? AttributedString(ns, including: \.uiKit) {
				valueText(attr)
			} else {
				valueText(ns.string)
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

// MARK: - Vertical fields

public func verticalField(_ label: String, _ value: String, isSubLabel: Bool = false) -> some View {
	VStack(alignment: .leading, spacing: 4) {
		if isSubLabel { fieldSubLabel(label) } else { fieldLabel(label) }
		multilineText(value)
	}
}

@ViewBuilder
public func verticalField<Content: View>(_ label: String, isSubLabel: Bool = false, @ViewBuilder _ content: () -> Content) -> some View {
	VStack(alignment: .leading, spacing: 4) {
		if !label.isEmpty {
			if isSubLabel { fieldSubLabel(label) } else { fieldLabel(label) }
		}
		content()
	}
}