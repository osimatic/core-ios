import Foundation
import UIKit

extension UIButton {
	static func getFloatingButton(color: UIColor = .tintColor) -> UIButton {
		return {
			let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60));
			//button.layer.masksToBounds = true;
			button.layer.cornerRadius = 30;
			button.layer.shadowRadius = 10;
			button.layer.shadowOpacity = 0.3;
			button.backgroundColor = color;
			button.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)), for: .normal);
			button.tintColor = .white;
			button.setTitleColor(.white, for: .normal);
			return button;
		}();
	}
	
	func setFloatingButtonPosition(_ view: UIView) {
		self.frame = CGRect(
			x: view.frame.size.width - 70,
			y: view.frame.size.height - 100,
			width: 60,
			height: 60
		);
	}
}
