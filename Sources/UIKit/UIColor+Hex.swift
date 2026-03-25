import Foundation
import UIKit

extension UIColor {
	public static var TEXT_SUCCESS = UIColor(hex: "198754");
	public static var TEXT_WARNING = UIColor(hex: "8A6D3B");
	public static var TEXT_DANGER = UIColor(hex: "A94442");
	public static var TEXT_INFO = UIColor(hex: "1AA3BE");
	
	public static var BG_SUCCESS = UIColor(hex: "DBF7D9");
	public static var BG_WARNING = UIColor(hex: "F7EDD9");
	public static var BG_DANGER = UIColor(hex: "F7D9D9");
	public static var BG_INFO = UIColor(hex: "D9EDF7");

	convenience init(hex:String) {
		var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
		hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

		var rgb: UInt32 = 0

		var r: CGFloat = 0.0
		var g: CGFloat = 0.0
		var b: CGFloat = 0.0
		var a: CGFloat = 1.0

		let length = String(hexSanitized).count;

		if Scanner(string: hexSanitized).scanHexInt32(&rgb) {
			if length == 6 {
				r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0;
				g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0;
				b = CGFloat(rgb & 0x0000FF) / 255.0;
			}
			else if length == 8 {
				r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0;
				g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0;
				b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0;
				a = CGFloat(rgb & 0x000000FF) / 255.0;
			}
		}

		self.init(red: r, green: g, blue: b, alpha: a)
	}
	
	static func colorWithHexString (hex:String) -> UIColor {
		return UIColor(hex:hex);
	}
	
	func toHex(alpha: Bool = false) -> String? {
		guard let components = cgColor.components, components.count >= 3 else {
			return nil;
		}

		let r = Float(components[0]);
		let g = Float(components[1]);
		let b = Float(components[2]);
		var a = Float(1.0);

		if components.count >= 4 {
			a = Float(components[3]);
		}

		if alpha {
			return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255));
		}
		
		return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255));
	}
	
	
}
