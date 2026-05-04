import Foundation
import UIKit

extension UILabel {
	func setHTMLFromString(_ text: String) {
		self.attributedText = text.toHtmlAttributedString(font: self.font);
	}
	func setHTMLFromAttributedString(_ text: NSAttributedString) {
		self.attributedText = HTMLAttributedString.setFont(text, font: self.font);
	}
	func setTextWithLineBreaks(_ text: String?) {
		guard let text = text else { self.text = nil; return; }
		self.attributedText = text.replacingOccurrences(of: "\n", with: "<br>").toHtmlAttributedString(font: self.font);
	}
}

extension UITextView {
	func setHTMLFromString(_ text: String) {
		self.attributedText = text.toHtmlAttributedString(font: self.font);
	}
	func setHTMLFromAttributedString(_ text: NSAttributedString) {
		self.attributedText = HTMLAttributedString.setFont(text, font: self.font);
	}
}
