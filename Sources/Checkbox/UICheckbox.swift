import SwiftUI
import UIKit

public final class UICheckbox: UIView {
	public var isChecked: Bool = false {
		didSet {
			guard !isUpdatingFromBinding, oldValue != isChecked else { return }
			hosting.rootView = makeView()
		}
	}
	public var onChange: ((Bool) -> Void)?

	private let label: String
	private let vertical: Bool
	private var isUpdatingFromBinding = false
	private var hosting: UIHostingController<CheckboxView>!

	public init(label: String, vertical: Bool = false) {
		self.label = label
		self.vertical = vertical
		super.init(frame: .zero)
		hosting = UIHostingController(rootView: makeView())
		hosting.view.backgroundColor = .clear
		addSubview(hosting.view)
		hosting.view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			hosting.view.topAnchor.constraint(equalTo: topAnchor),
			hosting.view.leadingAnchor.constraint(equalTo: leadingAnchor),
			hosting.view.trailingAnchor.constraint(equalTo: trailingAnchor),
			hosting.view.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}

	required init?(coder: NSCoder) { fatalError() }

	private func makeView() -> CheckboxView {
		CheckboxView(label, isChecked: Binding<Bool>(
			get: { [unowned self] in self.isChecked },
			set: { [weak self] newValue in
				guard let self else { return }
				self.isUpdatingFromBinding = true
				self.isChecked = newValue
				self.isUpdatingFromBinding = false
				self.onChange?(newValue)
			}
		), vertical: vertical)
	}
}