import UIKit

public extension UIBarButtonItem {
	static func cancelButton(target: Any?, action: Selector) -> UIBarButtonItem {
		let button = UIBarButtonItem(
			image: UIImage(systemName: "xmark"),
			style: .plain,
			target: target,
			action: action
		)
		button.tintColor = .secondaryLabel
		return button
	}
}