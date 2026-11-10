import Foundation
import UIKit

/*
 * Extension on String providing localization, attributed string, and URL-encoding helpers.
 */
public extension String {

	/*
	 * Returns the localized string for the given key.
	 * Checks Bundle.main first (host app can override), then falls back to Bundle.module (core-ios defaults).
	 *
	 * @param key The localization key.
	 * @return The localized string, or the key itself if no translation is found in either bundle.
	 */
	static func localize(_ key : String) -> String {
		let mainValue = NSLocalizedString(key, tableName: nil, bundle: Bundle.main, value: "", comment: "")
		if (!mainValue.isEmpty && mainValue != key) {
			return mainValue
		}
		return NSLocalizedString(key, tableName: nil, bundle: Bundle.module, value: key, comment: "")
	}

	/*
	 * Handles singular/plural forms in a string based on a number.
	 *
	 * {#} is replaced by the number. Each {...} group holds up to three alternatives separated by |, and is replaced by the one matching the number:
	 *  - three alternatives: zero, singular (1), plural;
	 *  - two alternatives: singular (0 and 1), plural;
	 *  - one alternative: empty for 0 and 1, the alternative otherwise.
	 *
	 * Examples:
	 *   String.pluralize("{No item|1 item|{#} items}", 0)  = "No item"
	 *   String.pluralize("{No item|1 item|{#} items}", 1)  = "1 item"
	 *   String.pluralize("{No item|1 item|{#} items}", 5)  = "5 items"
	 *   String.pluralize("{#} pointage{s}", 3)             = "3 pointages"
	 *   String.pluralize("{#} {cheval|chevaux}", 3)        = "3 chevaux"
	 *
	 * @param string The string to convert to singular or plural form.
	 * @param nb     The number of elements that determines whether the string is singular or plural.
	 * @return The string in singular or plural form.
	 */
	static func pluralize(_ string: String, _ nb: Double) -> String {
		let isWholeNumber = nb.isFinite && nb == nb.rounded() && abs(nb) < 9e15;
		var result = string.replacingOccurrences(of: "{#}", with: isWholeNumber ? String(Int64(nb)) : String(nb));

		guard let regex = try? NSRegularExpression(pattern: "\\{(.*?)\\}") else { return result; }
		let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result));
		// Matches are replaced from the last to the first so that the ranges of the previous ones stay valid
		for match in matches.reversed() {
			guard let fullRange = Range(match.range, in: result), let groupRange = Range(match.range(at: 1), in: result) else { continue; }
			let parts = result[groupRange].components(separatedBy: "|");
			let mod: String;
			if (nb == 0) {
				mod = parts.count == 1 ? "" : parts[0];
			} else if (nb == 1) {
				mod = parts.count == 1 ? "" : (parts.count == 2 ? parts[0] : parts[1]);
			} else {
				mod = parts.count == 1 ? parts[0] : (parts.count == 2 ? parts[1] : parts[2]);
			}
			result.replaceSubrange(fullRange, with: mod);
		}
		return result;
	}

	/*
	 * Same as pluralize(_:_:) with an integer number.
	 */
	static func pluralize(_ string: String, _ nb: Int) -> String {
		return pluralize(string, Double(nb));
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

		return (try? NSAttributedString(
			data: string.data(using: String.Encoding.unicode, allowLossyConversion: true)!,
			options: [
				NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
				NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
			],
			documentAttributes: nil
		)) ?? NSAttributedString(string: self);
	}

	/*
	 Returns the string with any trailing colon removed.
	 The string is first trimmed of whitespace and newlines on both ends,
	 then a final ':' (optionally preceded by whitespace) is stripped.
	 Example: "Email :" -> "Email", "Email:" -> "Email".
	 */
	func removingTrailingColon() -> String {
		let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines);
		guard trimmed.hasSuffix(":") else { return trimmed; }
		return String(trimmed.dropLast()).trimmingCharacters(in: .whitespacesAndNewlines);
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
public class HTMLAttributedString {

	/*
	 * Creates an NSAttributedString from an HTML string with optional font and alignment.
	 *
	 * @param str           The HTML source string.
	 * @param font          Optional font to apply.
	 * @param textAlignment Optional paragraph text alignment.
	 */
	public static func fromHtml(_ str: String, font: UIFont? = nil, textAlignment: NSTextAlignment? = nil) -> NSAttributedString {
		return str.toHtmlAttributedString(font: font, textAlignment: textAlignment);
	}

	/*
	 * Replaces the font attributes in an existing NSAttributedString over its full range.
	 *
	 * @param str  The source attributed string.
	 * @param font The font to apply. If nil, the original string is returned unchanged.
	 */
	public static func setFont(_ str: NSAttributedString, font: UIFont?) -> NSAttributedString {
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