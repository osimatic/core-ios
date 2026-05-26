import SwiftUI

// MARK: - Data models

public struct LabeledValue: Identifiable {
	public let id = UUID()
	public let label: String
	public let value: String

	public init(_ label: String, _ value: String) {
		self.label = label
		self.value = value
	}
}

public struct LabeledGroup: Identifiable {
	public let id = UUID()
	public let title: String
	public let rows: [LabeledValue]

	public init(_ title: String, rows: [LabeledValue]) {
		self.title = title
		self.rows = rows
	}
}

public enum ViewState {
	case loading
	case loaded([LabeledGroup])
	case error
}

// MARK: - Views

public struct ValueCard {
	public static func row(_ label: String, _ value: String) -> some View {
		row(LabeledValue(label, value))
	}

	public static func row(_ item: LabeledValue) -> some View {
		HStack(alignment: .firstTextBaseline, spacing: 8) {
			Text(item.label)
				.font(.system(size: 13))
				.foregroundColor(Color.secondary)
				.frame(maxWidth: .infinity, alignment: .leading)
			Text(item.value)
				.font(.system(size: 13, weight: .semibold))
				.multilineTextAlignment(.trailing)
		}
	}

	@ViewBuilder
	public static func card(_ rows: [LabeledValue], title: String = "", background: Color = Color(.systemBackground)) -> some View {
		Card(background: background) {
			if !title.isEmpty {
				Text(title).font(.system(size: 14, weight: .semibold))
			}
			ForEach(rows) { Self.row($0) }
		}
	}

	@ViewBuilder
	public static func infoCard(_ rows: [LabeledValue], title: String = "") -> some View {
		card(rows, title: title, background: Color(.systemBlue).opacity(0.15))
	}
}