import SwiftUI
import UIKit

public struct UICheckboxView: UIViewRepresentable {
	@Binding private var isChecked: Bool
	private let title: String

	fileprivate var titleColor: UIColor = .darkGray
	fileprivate var font: UIFont = .systemFont(ofSize: 16)
	fileprivate var stringTag: String?

	public init(title: String, isChecked: Binding<Bool>) {
		self.title = title
		self._isChecked = isChecked
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	public func makeUIView(context: Context) -> UICheckbox {
		let checkbox = UICheckbox(frame: .zero)
		checkbox.onSelect = { button in
			context.coordinator.parent.isChecked = button.isSelected
		}
		return checkbox
	}

	public func updateUIView(_ uiView: UICheckbox, context: Context) {
		context.coordinator.parent = self
		uiView.setTitle(title, for: .normal)
		uiView.setTitleColor(titleColor, for: .normal)
		uiView.titleLabel?.font = font
		uiView.stringTag = stringTag
		if uiView.isSelected != isChecked {
			uiView.isSelected = isChecked
		}
	}

	public class Coordinator {
		var parent: UICheckboxView
		init(_ parent: UICheckboxView) { self.parent = parent }
	}
}

public extension UICheckboxView {
	func titleColor(_ value: UIColor) -> Self { var copy = self; copy.titleColor = value; return copy }
	func font(_ value: UIFont) -> Self { var copy = self; copy.font = value; return copy }
	func stringTag(_ value: String?) -> Self { var copy = self; copy.stringTag = value; return copy }
}