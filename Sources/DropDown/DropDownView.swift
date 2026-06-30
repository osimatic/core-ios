import SwiftUI
import UIKit

public struct DropDownView: UIViewRepresentable {
	@Binding private var selection: DropDownItem?
	private let options: [DropDownItem]
	private let placeholder: String

	fileprivate var rowHeight: CGFloat = 30
	fileprivate var rowBackgroundColor: UIColor = .white
	fileprivate var itemsColor: UIColor = .darkGray
	fileprivate var itemsTintColor: UIColor = .blue
	fileprivate var selectedRowColor: UIColor = .systemPink
	fileprivate var hideOptionsWhenSelect: Bool = true
	fileprivate var isSearchEnable: Bool = true
	fileprivate var borderColor: UIColor = .lightGray
	fileprivate var listHeight: CGFloat = 150
	fileprivate var borderWidth: CGFloat = 0.0
	fileprivate var cornerRadius: CGFloat = 5.0
	fileprivate var arrowSize: CGFloat = 15
	fileprivate var arrowColor: UIColor = .black
	fileprivate var checkMarkEnabled: Bool = true
	fileprivate var handleKeyboard: Bool = true
	fileprivate var font: UIFont?
	fileprivate var textColor: UIColor?
	fileprivate var textAlignment: NSTextAlignment = .natural
	fileprivate var optionImageArray: [String] = []
	fileprivate var optionIds: [Int]?

	fileprivate var onSelect: ((String, Int, Int) -> Void)?
	fileprivate var onListWillAppear: (() -> Void)?
	fileprivate var onListDidAppear: (() -> Void)?
	fileprivate var onListWillDisappear: (() -> Void)?
	fileprivate var onListDidDisappear: (() -> Void)?

	public init(options: [DropDownItem], selection: Binding<DropDownItem?>, placeholder: String = "") {
		self.options = options
		self._selection = selection
		self.placeholder = placeholder
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	public func makeUIView(context: Context) -> DropDown {
		let dropDown = DropDown(frame: .zero)
		dropDown.setContentHuggingPriority(.defaultLow, for: .horizontal)
		dropDown.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		dropDown.didSelect { text, index, id in
			context.coordinator.handleSelection(index: index, text: text, id: id)
		}
		dropDown.listWillAppear { context.coordinator.parent.onListWillAppear?() }
		dropDown.listDidAppear { context.coordinator.parent.onListDidAppear?() }
		dropDown.listWillDisappear { context.coordinator.parent.onListWillDisappear?() }
		dropDown.listDidDisappear { context.coordinator.parent.onListDidDisappear?() }
		return dropDown
	}

	public func updateUIView(_ uiView: DropDown, context: Context) {
		context.coordinator.parent = self

		uiView.optionArray = options
		uiView.optionImageArray = optionImageArray
		uiView.optionIds = optionIds
		uiView.placeholder = placeholder
		uiView.rowHeight = rowHeight
		uiView.rowBackgroundColor = rowBackgroundColor
		uiView.itemsColor = itemsColor
		uiView.itemsTintColor = itemsTintColor
		uiView.selectedRowColor = selectedRowColor
		uiView.hideOptionsWhenSelect = hideOptionsWhenSelect
		uiView.isSearchEnable = isSearchEnable
		uiView.borderColor = borderColor
		uiView.listHeight = listHeight
		uiView.borderWidth = borderWidth
		uiView.cornerRadius = cornerRadius
		uiView.arrowSize = arrowSize
		uiView.arrowColor = arrowColor
		uiView.checkMarkEnabled = checkMarkEnabled
		uiView.handleKeyboard = handleKeyboard
		uiView.textAlignment = textAlignment
		if let font = font { uiView.font = font }
		if let textColor = textColor { uiView.textColor = textColor }

		context.coordinator.syncSelection(uiView: uiView, selection: selection)
	}

	public class Coordinator {
		var parent: DropDownView
		fileprivate var lastAppliedLabel: String?

		init(_ parent: DropDownView) {
			self.parent = parent
		}

		func handleSelection(index: Int, text: String, id: Int) {
			if index >= 0 && index < parent.options.count {
				lastAppliedLabel = parent.options[index].getLabel()
				parent.selection = parent.options[index]
			}
			parent.onSelect?(text, index, id)
		}

		func syncSelection(uiView: DropDown, selection: DropDownItem?) {
			let label = selection?.getLabel()
			if label == lastAppliedLabel { return }
			lastAppliedLabel = label
			if let selection = selection {
				uiView.setSelectedItem(selection)
			} else {
				uiView.selectedIndex = nil
				uiView.text = ""
			}
		}
	}
}

public extension DropDownView {
	func rowHeight(_ value: CGFloat) -> Self { var copy = self; copy.rowHeight = value; return copy }
	func rowBackgroundColor(_ value: UIColor) -> Self { var copy = self; copy.rowBackgroundColor = value; return copy }
	func itemsColor(_ value: UIColor) -> Self { var copy = self; copy.itemsColor = value; return copy }
	func itemsTintColor(_ value: UIColor) -> Self { var copy = self; copy.itemsTintColor = value; return copy }
	func selectedRowColor(_ value: UIColor) -> Self { var copy = self; copy.selectedRowColor = value; return copy }
	func hideOptionsWhenSelect(_ value: Bool) -> Self { var copy = self; copy.hideOptionsWhenSelect = value; return copy }
	func searchEnabled(_ value: Bool) -> Self { var copy = self; copy.isSearchEnable = value; return copy }
	func borderColor(_ value: UIColor) -> Self { var copy = self; copy.borderColor = value; return copy }
	func listHeight(_ value: CGFloat) -> Self { var copy = self; copy.listHeight = value; return copy }
	func borderWidth(_ value: CGFloat) -> Self { var copy = self; copy.borderWidth = value; return copy }
	func cornerRadius(_ value: CGFloat) -> Self { var copy = self; copy.cornerRadius = value; return copy }
	func arrowSize(_ value: CGFloat) -> Self { var copy = self; copy.arrowSize = value; return copy }
	func arrowColor(_ value: UIColor) -> Self { var copy = self; copy.arrowColor = value; return copy }
	func checkMarkEnabled(_ value: Bool) -> Self { var copy = self; copy.checkMarkEnabled = value; return copy }
	func handleKeyboard(_ value: Bool) -> Self { var copy = self; copy.handleKeyboard = value; return copy }
	func font(_ value: UIFont) -> Self { var copy = self; copy.font = value; return copy }
	func textColor(_ value: UIColor) -> Self { var copy = self; copy.textColor = value; return copy }
	func textAlignment(_ value: NSTextAlignment) -> Self { var copy = self; copy.textAlignment = value; return copy }
	func optionImages(_ value: [String]) -> Self { var copy = self; copy.optionImageArray = value; return copy }
	func optionIds(_ value: [Int]) -> Self { var copy = self; copy.optionIds = value; return copy }

	func onSelect(_ handler: @escaping (_ selectedText: String, _ index: Int, _ id: Int) -> Void) -> Self {
		var copy = self; copy.onSelect = handler; return copy
	}
	func onListWillAppear(_ handler: @escaping () -> Void) -> Self { var copy = self; copy.onListWillAppear = handler; return copy }
	func onListDidAppear(_ handler: @escaping () -> Void) -> Self { var copy = self; copy.onListDidAppear = handler; return copy }
	func onListWillDisappear(_ handler: @escaping () -> Void) -> Self { var copy = self; copy.onListWillDisappear = handler; return copy }
	func onListDidDisappear(_ handler: @escaping () -> Void) -> Self { var copy = self; copy.onListDidDisappear = handler; return copy }

	public static func field(
		_ options: [DropDownItem],
		selection: Binding<DropDownItem?>,
		placeholder: String,
		listHeight: CGFloat = UIScreen.main.bounds.height * 0.5
	) -> some View {
		DropDownView(options: options, selection: selection, placeholder: placeholder)
			.listHeight(listHeight)
			.frame(maxWidth: .infinity)
			.frame(height: 40)
	}
}