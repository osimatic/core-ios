import SwiftUI

public struct CheckboxView: View {
	private let label: String?
	private let attributedLabel: AttributedString?
	@Binding private var isChecked: Bool
	private let vertical: Bool

	public init(_ label: String, isChecked: Binding<Bool>, vertical: Bool = false) {
		self.label = label
		self.attributedLabel = nil
		self._isChecked = isChecked
		self.vertical = vertical
	}

	public init(_ label: AttributedString, isChecked: Binding<Bool>, vertical: Bool = false) {
		self.label = nil
		self.attributedLabel = label
		self._isChecked = isChecked
		self.vertical = vertical
	}

	public var body: some View {
		Button { isChecked.toggle() } label: {
			if vertical {
				VStack(spacing: 4) { icon; text }
					.frame(maxWidth: .infinity)
			} else {
				HStack(alignment: .top, spacing: 8) { icon; text }
			}
		}
		.buttonStyle(.plain)
	}

	private var icon: some View {
		SwiftUI.Image(systemName: isChecked ? "checkmark.square.fill" : "square")
			.foregroundColor(isChecked ? Color.accentColor : Color.secondary)
			.font(.system(size: vertical ? 22 : 20))
	}

	@ViewBuilder
	private var text: some View {
		if let attributedLabel {
			Text(attributedLabel)
				.font(.system(size: vertical ? 11 : 14))
				.foregroundColor(Color.primary)
				.tint(Color.accentColor)
		} else {
			Text(label ?? "")
				.font(.system(size: vertical ? 11 : 14))
				.foregroundColor(Color.primary)
		}
	}
}