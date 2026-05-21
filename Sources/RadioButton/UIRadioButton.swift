import SwiftUI
import UIKit

public final class UIRadioButton<Tag: Hashable>: UIView {
	public var selection: Tag? {
		didSet {
			guard !isUpdatingFromBinding, oldValue != selection else { return }
			hosting.rootView = makeView()
		}
	}
	public var onChange: ((Tag?) -> Void)?

	private let label: String
	private let tag: Tag
	private var isUpdatingFromBinding = false
	private lazy var hosting = UIHostingController(rootView: makeView())

	public init(label: String, tag: Tag) {
		self.label = label
		self.tag = tag
		super.init(frame: .zero)
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

	private func makeView() -> RadioButtonView<Tag> {
		RadioButtonView(label, tag: tag, selection: Binding(
			get: { [unowned self] in self.selection },
			set: { [weak self] newValue in
				guard let self else { return }
				self.isUpdatingFromBinding = true
				self.selection = newValue
				self.isUpdatingFromBinding = false
				self.onChange?(newValue)
			}
		))
	}
}