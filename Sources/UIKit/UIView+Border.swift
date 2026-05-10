import Foundation
import UIKit

public extension UIView {
	func viewBorder(borderColor: UIColor, borderWidth: CGFloat?) {
		layer.borderColor = borderColor.cgColor
		if let borderWidth_ = borderWidth {
			layer.borderWidth = borderWidth_
		} else {
			layer.borderWidth = 1.0
		}
	}
}
