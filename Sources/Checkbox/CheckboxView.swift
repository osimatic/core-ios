import SwiftUI

public struct CheckboxView: View {
	private let label: String
	@Binding private var isChecked: Bool
	private let vertical: Bool

	public init(_ label: String, isChecked: Binding<Bool>, vertical: Bool = false) {
		self.label = label
		self._isChecked = isChecked
		self.vertical = vertical
	}

	public var body: some View {
		Button { isChecked.toggle() } label: {
			if vertical {
				VStack(spacing: 4) { icon; text }
			} else {
				HStack(spacing: 8) { icon; text }
			}
		}
		.buttonStyle(.plain)
	}

	private var icon: some View {
		Image(systemName: isChecked ? "checkmark.square.fill" : "square")
			.foregroundColor(isChecked ? .accentColor : .secondary)
			.font(.system(size: vertical ? 22 : 20))
	}

	private var text: some View {
		Text(label)
			.font(.system(size: vertical ? 11 : 14))
			.foregroundColor(vertical ? .secondary : .primary)
	}
}