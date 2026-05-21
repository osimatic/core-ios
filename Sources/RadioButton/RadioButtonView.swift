import SwiftUI

public struct RadioButtonView<Tag: Hashable>: View {
	private let label: String
	private let tag: Tag
	@Binding private var selection: Tag?

	public init(_ label: String, tag: Tag, selection: Binding<Tag?>) {
		self.label = label
		self.tag = tag
		self._selection = selection
	}

	public init(_ label: String, tag: Tag, selection: Binding<Tag>) {
		self.label = label
		self.tag = tag
		self._selection = Binding<Tag?>(
			get: { selection.wrappedValue },
			set: { if let v = $0 { selection.wrappedValue = v } }
		)
	}

	public var body: some View {
		Button { selection = tag } label: {
			HStack(spacing: 8) {
				SwiftUI.Image(systemName: selection == tag ? "largecircle.fill.circle" : "circle")
					.foregroundColor(selection == tag ? Color.accentColor : Color.secondary)
				Text(label).font(.system(size: 14)).foregroundColor(Color.primary)
			}
		}
		.buttonStyle(.plain)
	}

	// MARK: - Group

	public static func vertical(_ opts: [(tag: Tag, label: String)], selection: Binding<Tag?>) -> some View {
		VStack(alignment: .leading, spacing: 4) {
			ForEach(Array(opts.enumerated()), id: \.offset) { (_, o) in
				RadioButtonView(o.label, tag: o.tag, selection: selection)
			}
		}
	}

	@ViewBuilder
	public static func vertical(_ opts: [(tag: Tag, label: String)], selection: Binding<Tag>) -> some View {
		vertical(opts, selection: Binding<Tag?>(
			get: { selection.wrappedValue },
			set: { if let v = $0 { selection.wrappedValue = v } }
		))
	}

	public static func horizontal(_ opts: [(tag: Tag, label: String)], selection: Binding<Tag?>) -> some View {
		HStack(spacing: 16) {
			ForEach(Array(opts.enumerated()), id: \.offset) { (_, o) in
				RadioButtonView(o.label, tag: o.tag, selection: selection)
			}
		}.frame(height: 30)
	}

	public static func horizontal(_ opts: [(tag: Tag, label: String)], selection: Binding<Tag>) -> some View {
		horizontal(opts, selection: Binding<Tag?>(
			get: { selection.wrappedValue },
			set: { (v: Tag?) in if let v { selection.wrappedValue = v } }
		))
	}
}

public extension RadioButtonView where Tag == Bool {
	static func yesNo(_ selection: Binding<Bool>, trueLabel: String = "Yes", falseLabel: String = "No") -> some View {
		RadioButtonView<Bool>.horizontal([(tag: false, label: falseLabel), (tag: true, label: trueLabel)], selection: selection)
	}
}
