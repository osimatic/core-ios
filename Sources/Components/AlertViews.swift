import SwiftUI
import UIKit

// MARK: - Alert messages

private func alertMessage<C: View>(_ text: String, icon: String, color: Color, @ViewBuilder additional: () -> C) -> some View {
	VStack(alignment: .leading, spacing: 8) {
		HStack(alignment: .top, spacing: 8) {
			SwiftUI.Image(systemName: icon).foregroundColor(color)
			multilineText(text)
		}
		additional()
	}
	.padding(8)
	.frame(maxWidth: .infinity, alignment: .leading)
	.background(color.opacity(0.15))
	.cornerRadius(6)
}

public func warningMessage(_ text: String) -> some View {
	alertMessage(text, icon: "exclamationmark.triangle.fill", color: .orange) { EmptyView() }
}
public func warningMessage<C: View>(_ text: String, @ViewBuilder content: () -> C) -> some View {
	alertMessage(text, icon: "exclamationmark.triangle.fill", color: .orange, additional: content)
}

public func dangerMessage(_ text: String) -> some View {
	alertMessage(text, icon: "xmark.circle.fill", color: .red) { EmptyView() }
}
public func dangerMessage<C: View>(_ text: String, @ViewBuilder content: () -> C) -> some View {
	alertMessage(text, icon: "xmark.circle.fill", color: .red, additional: content)
}

public func infoMessage(_ text: String) -> some View {
	alertMessage(text, icon: "info.circle.fill", color: Color(.systemBlue)) { EmptyView() }
}
public func infoMessage<C: View>(_ text: String, @ViewBuilder content: () -> C) -> some View {
	alertMessage(text, icon: "info.circle.fill", color: Color(.systemBlue), additional: content)
}

public func successMessage(_ text: String) -> some View {
	alertMessage(text, icon: "checkmark.circle.fill", color: .green) { EmptyView() }
}
public func successMessage<C: View>(_ text: String, @ViewBuilder content: () -> C) -> some View {
	alertMessage(text, icon: "checkmark.circle.fill", color: .green, additional: content)
}

// MARK: - UIKit bridge

public struct ChildVCView: UIViewControllerRepresentable {
	public let viewController: UIViewController

	public init(_ viewController: UIViewController) {
		self.viewController = viewController
	}

	public func makeUIViewController(context: Context) -> UIViewController { viewController }
	public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}