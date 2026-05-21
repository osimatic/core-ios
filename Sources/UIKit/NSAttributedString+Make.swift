import UIKit

public extension NSAttributedString {
	static func make(
		_ text: String,
		font: UIFont? = nil,
		color: UIColor? = nil,
		italic: Bool = false,
		bold: Bool = false,
		strikethrough: Bool = false,
		alignment: NSTextAlignment? = nil
	) -> NSAttributedString {
		let baseFont = font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
		var traits: UIFontDescriptor.SymbolicTraits = []
		if italic { traits.insert(.traitItalic) }
		if bold   { traits.insert(.traitBold) }
		let descriptor = traits.isEmpty
			? baseFont.fontDescriptor
			: (baseFont.fontDescriptor.withSymbolicTraits(traits) ?? baseFont.fontDescriptor)
		let styledFont = UIFont(descriptor: descriptor, size: baseFont.pointSize)

		var attrs: [NSAttributedString.Key: Any] = [.font: styledFont]
		if let color = color { attrs[.foregroundColor] = color }
		if strikethrough     { attrs[.strikethroughStyle] = NSUnderlineStyle.single.rawValue }
		if let alignment = alignment {
			let ps = NSMutableParagraphStyle()
			ps.alignment = alignment
			attrs[.paragraphStyle] = ps
		}
		return NSAttributedString(string: text, attributes: attrs)
	}
}