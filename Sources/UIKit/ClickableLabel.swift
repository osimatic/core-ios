import Foundation
import UIKit

class ClickableLabel: UILabel {
	var onClick: () -> Void = {};
	
	func setLink(_ text: String, url: String) {
		setLink(text, onClick: {
			let url = URL(string: url)!;
			UIApplication.shared.open(url);
		});
	}
	
	func setLink(_ text: String, onClick: @escaping () -> Void = {}) {
		let textRange = NSRange(location: 0, length: text.count);
		let attributedText = NSMutableAttributedString(string: text);
		attributedText.addAttribute(.foregroundColor, value: UIColor(red:0.05, green:0.4, blue:0.65, alpha:1.0), range: textRange);
		attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: textRange);
		self.attributedText = attributedText;
		
		// Gesture recognizer Label
		self.onClick = onClick;
		let tapLabel = UITapGestureRecognizer(target: self, action: #selector(tapFunction));
		self.isUserInteractionEnabled = true;
		self.addGestureRecognizer(tapLabel);
	}
	
	@objc func tapFunction(sender: UITapGestureRecognizer) {
		NSLog("tapFunction");
		onClick();
	}
}

/*
extension UITapGestureRecognizer {
	func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
		// Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
		let layoutManager = NSLayoutManager()
		let textContainer = NSTextContainer(size: CGSize.zero)
		let textStorage = NSTextStorage(attributedString: label.attributedText!)

		// Configure layoutManager and textStorage
		layoutManager.addTextContainer(textContainer)
		textStorage.addLayoutManager(layoutManager)

		// Configure textContainer
		textContainer.lineFragmentPadding = 0.0
		textContainer.lineBreakMode = label.lineBreakMode
		textContainer.maximumNumberOfLines = label.numberOfLines
		let labelSize = label.bounds.size
		textContainer.size = labelSize

		// Find the tapped character location and compare it to the specified range
		let locationOfTouchInLabel = self.location(in: label)
		let textBoundingBox = layoutManager.usedRect(for: textContainer)
		let textContainerOffset = CGPoint(
			x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
			y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
		)
		let locationOfTouchInTextContainer = CGPoint(
			x: locationOfTouchInLabel.x - textContainerOffset.x,
			y: locationOfTouchInLabel.y - textContainerOffset.y
		)
		let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

		return NSLocationInRange(indexOfCharacter, targetRange)
	}
}
*/

