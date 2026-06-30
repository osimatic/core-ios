import SwiftUI

public struct TimeRangePickerView: View {
	@Binding var startTime: Date
	@Binding var endTime: Date
	var isSubLabel: Bool
	var onChanged: (() -> Void)?

	public init(
		startTime: Binding<Date>,
		endTime: Binding<Date>,
		isSubLabel: Bool = false,
		onChanged: (() -> Void)? = nil
	) {
		self._startTime = startTime
		self._endTime = endTime
		self.isSubLabel = isSubLabel
		self.onChanged = onChanged
	}

	public var body: some View {
		HStack(spacing: 12) {
			verticalField(String.localize("timeRangeFrom"), isSubLabel: isSubLabel) {
				DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
					.labelsHidden()
					.onChange(of: startTime) { _ in onChanged?() }
			}
			verticalField(String.localize("timeRangeTo"), isSubLabel: isSubLabel) {
				DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
					.labelsHidden()
					.onChange(of: endTime) { _ in onChanged?() }
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}