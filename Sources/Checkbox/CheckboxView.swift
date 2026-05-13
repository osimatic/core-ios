import SwiftUI
import UIKit

public struct CheckboxView: UIViewRepresentable {
	@Binding private var isChecked: Bool

	fileprivate var checkedBackgroundColor: UIColor = #colorLiteral(red: 0.1450980392, green: 0.3450980392, blue: 0.5098039216, alpha: 1)
	fileprivate var uncheckedBackgroundColor: UIColor = .white
	fileprivate var checkedBorderColor: UIColor = .black
	fileprivate var uncheckedBorderColor: UIColor = .black
	fileprivate var checkedImage: UIImage? = UIImage(systemName: "checkmark")
	fileprivate var imageTint: UIColor? = .white
	fileprivate var checkedViewInsets: UIEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
	fileprivate var hitRadiusOffset: CGFloat = 10

	public init(isChecked: Binding<Bool>) {
		self._isChecked = isChecked
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	public func makeUIView(context: Context) -> Checkbox {
		let checkbox = Checkbox(frame: .zero)
		checkbox.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
		return checkbox
	}

	public func updateUIView(_ uiView: Checkbox, context: Context) {
		context.coordinator.parent = self
		uiView.checkedBackgroundColor = checkedBackgroundColor
		uiView.uncheckedBackgroundColor = uncheckedBackgroundColor
		uiView.checkedBorderColor = checkedBorderColor
		uiView.uncheckedBorderColor = uncheckedBorderColor
		uiView.checkedImage = checkedImage
		uiView.imageTint = imageTint
		uiView.checkedViewInsets = checkedViewInsets
		uiView.hitRadiusOffset = hitRadiusOffset
		if uiView.isChecked != isChecked {
			uiView.isChecked = isChecked
		}
	}

	public class Coordinator {
		var parent: CheckboxView
		init(_ parent: CheckboxView) { self.parent = parent }

		@objc func valueChanged(_ sender: Checkbox) {
			parent.isChecked = sender.isChecked
		}
	}
}

public extension CheckboxView {
	func checkedBackgroundColor(_ value: UIColor) -> Self { var copy = self; copy.checkedBackgroundColor = value; return copy }
	func uncheckedBackgroundColor(_ value: UIColor) -> Self { var copy = self; copy.uncheckedBackgroundColor = value; return copy }
	func checkedBorderColor(_ value: UIColor) -> Self { var copy = self; copy.checkedBorderColor = value; return copy }
	func uncheckedBorderColor(_ value: UIColor) -> Self { var copy = self; copy.uncheckedBorderColor = value; return copy }
	func checkedImage(_ value: UIImage?) -> Self { var copy = self; copy.checkedImage = value; return copy }
	func imageTint(_ value: UIColor?) -> Self { var copy = self; copy.imageTint = value; return copy }
	func checkedViewInsets(_ value: UIEdgeInsets) -> Self { var copy = self; copy.checkedViewInsets = value; return copy }
	func hitRadiusOffset(_ value: CGFloat) -> Self { var copy = self; copy.hitRadiusOffset = value; return copy }
}