import SwiftUI
import UIKit

public struct RadioButtonView<Tag: Hashable>: UIViewRepresentable {
	@Binding private var selection: Tag?
	private let tag: Tag
	private let title: String

	fileprivate var titleColor: UIColor = .darkGray
	fileprivate var font: UIFont = .systemFont(ofSize: 16)
	fileprivate var stringTag: String?

	public init(title: String, tag: Tag, selection: Binding<Tag?>) {
		self.title = title
		self.tag = tag
		self._selection = selection
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	public func makeUIView(context: Context) -> UIRadioButton {
		let radio = UIRadioButton(frame: .zero)
		radio.onSelect = { _ in
			context.coordinator.parent.selection = context.coordinator.parent.tag
		}
		return radio
	}

	public func updateUIView(_ uiView: UIRadioButton, context: Context) {
		context.coordinator.parent = self
		uiView.setTitle(title, for: .normal)
		uiView.setTitleColor(titleColor, for: .normal)
		uiView.titleLabel?.font = font
		uiView.stringTag = stringTag
		let shouldBeSelected = (selection == tag)
		if uiView.isSelected != shouldBeSelected {
			uiView.isSelected = shouldBeSelected
		}
	}

	public class Coordinator {
		var parent: RadioButtonView
		init(_ parent: RadioButtonView) { self.parent = parent }
	}
}

public extension RadioButtonView {
	func titleColor(_ value: UIColor) -> Self { var copy = self; copy.titleColor = value; return copy }
	func font(_ value: UIFont) -> Self { var copy = self; copy.font = value; return copy }
	func stringTag(_ value: String?) -> Self { var copy = self; copy.stringTag = value; return copy }
}