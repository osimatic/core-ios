import Foundation
import UIKit

extension UITextField {
	fileprivate func setPasswordToggleImage(_ button: UIButton) {
		if (isSecureTextEntry) {
			button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal);
		}
		else {
			button.setImage(UIImage(systemName: "eye.fill"), for: .normal);
		}
	}

	func enablePasswordToggle() {
		let button = UIButton(type: .custom);
		setPasswordToggleImage(button);
		button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0);
		button.frame = CGRect(x: CGFloat(self.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25));
		button.addTarget(self, action: #selector(self.togglePasswordView), for: .touchUpInside);
		self.rightView = button;
		self.rightViewMode = .always;
	}
	
	@IBAction func togglePasswordView(_ sender: Any) {
		//self.isSecureTextEntry = !self.isSecureTextEntry
		isSecureTextEntry = !isSecureTextEntry;

		if let existingText = text, isSecureTextEntry {
			/* When toggling to secure text, all text will be purged if the user
			 continues typing unless we intervene. This is prevented by first
			 deleting the existing text and then recovering the original text. */
			deleteBackward();

			if let textRange = textRange(from: beginningOfDocument, to: endOfDocument) {
				replace(textRange, withText: existingText);
			}
		}

		/* Reset the selected text range since the cursor can end up in the wrong
		 position after a toggle because the text might vary in width */
		if let existingSelectedTextRange = selectedTextRange {
			selectedTextRange = nil;
			selectedTextRange = existingSelectedTextRange;
		}
		
		setPasswordToggleImage(sender as! UIButton);
	}
}
