import Foundation
import UIKit

/*
 * Extension on String providing localization, attributed string, and URL-encoding helpers.
 */
extension String {

	/*
	 * Returns the localized string for the given key using the main bundle.
	 *
	 * @param key The localization key.
	 * @return The localized string, or the key itself if no translation is found.
	 */
	static func localize(_ key : String) -> String {
		return NSLocalizedString(key, tableName: nil, bundle: Bundle.main, value: "", comment: "")
	}

	/*
	 * Converts this string into an NSAttributedString with optional font and text alignment.
	 *
	 * @param font          Optional font to apply.
	 * @param textAlignment Optional paragraph text alignment.
	 */
	func toAttributedString(font: UIFont? = nil, textAlignment: NSTextAlignment? = nil) -> NSAttributedString {
		var attributes: [NSAttributedString.Key : Any] = [:];
		if let font = font {
			attributes[.font] = font;
		}
		if let textAlignment = textAlignment {
			let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
			paragraphStyle.alignment = textAlignment;
			attributes[.paragraphStyle] = paragraphStyle;
		}

		return NSAttributedString(string: self, attributes: attributes);
	}

	/*
	 * Parses this string as HTML and returns an NSAttributedString.
	 * Optionally wraps the content in a <span> tag to apply a system font.
	 *
	 * @param font          Optional font to apply via inline CSS.
	 * @param textAlignment Optional paragraph text alignment.
	 */
	func toHtmlAttributedString(font: UIFont? = nil, textAlignment: NSTextAlignment? = nil) -> NSAttributedString {
		var string = self;
		if let font = font {
			string = String(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(font.pointSize)\">%@</span>", self);
		}

		return try! NSAttributedString(
			data: string.data(using: String.Encoding.unicode, allowLossyConversion: true)!,
			options: [
				NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
				NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
			],
			documentAttributes: nil
		);
	}

	/*
	 * Returns a percent-encoded version of this string suitable for use in a URL query.
	 * Uses RFC 3986 unreserved characters.
	 */
	func urlEncoded() -> String {
		let urlAllowed: CharacterSet = .alphanumerics.union(.init(charactersIn: "-._~")); // RFC 3986
		return self.addingPercentEncoding(withAllowedCharacters: urlAllowed) ?? "";
	}
}

/*
 * Utility class for creating and applying fonts to HTML-sourced attributed strings.
 */
class HTMLAttributedString {

	/*
	 * Creates an NSAttributedString from an HTML string with optional font and alignment.
	 *
	 * @param str           The HTML source string.
	 * @param font          Optional font to apply.
	 * @param textAlignment Optional paragraph text alignment.
	 */
	static func fromHtml(_ str: String, font: UIFont? = nil, textAlignment: NSTextAlignment? = nil) -> NSAttributedString {
		return str.toHtmlAttributedString(font: font, textAlignment: textAlignment);
	}

	/*
	 * Replaces the font attributes in an existing NSAttributedString over its full range.
	 *
	 * @param str  The source attributed string.
	 * @param font The font to apply. If nil, the original string is returned unchanged.
	 */
	static func setFont(_ str: NSAttributedString, font: UIFont?) -> NSAttributedString {
		NSLog("setFont");
		guard let font = font else {
			NSLog("no font");
			return str;

		}

		let text = NSMutableAttributedString(attributedString: str);
		text.setAttributes([NSAttributedString.Key.font: font], range: NSRange(location: 0, length: str.string.count));

		return text;
	}
}