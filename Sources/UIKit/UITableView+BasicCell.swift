import Foundation
import UIKit

extension UITableView {
	func getBasicCell(identifier: String = "basicCell", backgroundColor: UIColor? = nil) -> UITableViewCell {
		if let cell = self.dequeueReusableCell(withIdentifier: identifier) {
			if let backgroundColor = backgroundColor {
				cell.backgroundColor = backgroundColor;
			}
			return cell;
		}
		let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "basicCell");
		if let backgroundColor = backgroundColor {
			cell.backgroundColor = backgroundColor;
		}
		return cell;
	}
	
}
