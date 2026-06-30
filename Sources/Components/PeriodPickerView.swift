import SwiftUI

/*
 * Pair of DatePickers (start / end) with automatic end-date correction:
 * when startDate changes and becomes later than endDate, endDate is updated
 * to match — SwiftUI's DatePicker does not update the binding itself when
 * the `in: startDate...` constraint makes the current value invalid.
 * Default layout: HStack(spacing: 12). Graphical style: vertical with Divider.
 */
public struct PeriodPickerView: View {
	@Binding var startDate: Date
	@Binding var endDate: Date
	var isSubLabel: Bool
	var graphicalStyle: Bool
	var onChanged: (() -> Void)?

	public init(
		startDate: Binding<Date>,
		endDate: Binding<Date>,
		isSubLabel: Bool = false,
		graphicalStyle: Bool = false,
		onChanged: (() -> Void)? = nil
	) {
		self._startDate = startDate
		self._endDate = endDate
		self.isSubLabel = isSubLabel
		self.graphicalStyle = graphicalStyle
		self.onChanged = onChanged
	}

	@ViewBuilder
	private var fromPicker: some View {
		DatePicker("", selection: $startDate, displayedComponents: .date)
			.labelsHidden()
			.onChange(of: startDate) { newValue in
				if (newValue > endDate) { endDate = newValue }
				onChanged?()
			}
			.graphicalStyleIfNeeded(graphicalStyle)
	}

	@ViewBuilder
	private var toPicker: some View {
		DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
			.labelsHidden()
			.onChange(of: endDate) { _ in onChanged?() }
			.graphicalStyleIfNeeded(graphicalStyle)
	}

	public var body: some View {
		if (graphicalStyle) {
			Group {
				verticalField(String.localize("periodFrom"), isSubLabel: isSubLabel) { fromPicker }
				Divider()
				verticalField(String.localize("periodTo"), isSubLabel: isSubLabel) { toPicker }
			}
		} else {
			HStack(spacing: 12) {
				verticalField(String.localize("periodFrom"), isSubLabel: isSubLabel) { fromPicker }
				verticalField(String.localize("periodTo"), isSubLabel: isSubLabel) { toPicker }
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
	}
}

private extension View {
	@ViewBuilder
	func graphicalStyleIfNeeded(_ apply: Bool) -> some View {
		if (apply) {
			self.datePickerStyle(.graphical)
		} else {
			self
		}
	}
}