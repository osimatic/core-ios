import SwiftUI

/*
 * Pair of DatePickers (start / end) with automatic end-date correction:
 * when startDate changes and becomes later than endDate, endDate is updated
 * to match — SwiftUI's DatePicker does not update the binding itself when
 * the `in: startDate...` constraint makes the current value invalid.
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

	public var body: some View {
		Group {
			verticalField(String.localize("periodFrom"), isSubLabel: isSubLabel) {
				DatePicker("", selection: $startDate, displayedComponents: .date)
					.labelsHidden()
					.onChange(of: startDate) { newValue in
						if (newValue > endDate) {
                            endDate = newValue
                        }
						onChanged?()
					}
					.graphicalStyleIfNeeded(graphicalStyle)
			}
			if (graphicalStyle) {
                Divider()
            }
			verticalField(String.localize("periodTo"), isSubLabel: isSubLabel) {
				DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
					.labelsHidden()
					.onChange(of: endDate) { _ in onChanged?() }
					.graphicalStyleIfNeeded(graphicalStyle)
			}
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