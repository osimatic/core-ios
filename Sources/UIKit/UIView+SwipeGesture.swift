import Foundation
import UIKit

extension UIView {
	func addSwipeGesture(target: Any, selector: Selector) {
		let leftSwipeGesture = UISwipeGestureRecognizer(target: target, action: selector);
		let rightSwipeGesture = UISwipeGestureRecognizer(target: target, action: selector);
		
		leftSwipeGesture.direction = UISwipeGestureRecognizer.Direction.left;
		rightSwipeGesture.direction = UISwipeGestureRecognizer.Direction.right;

		self.addGestureRecognizer(leftSwipeGesture);
		self.addGestureRecognizer(rightSwipeGesture);
	}
}
