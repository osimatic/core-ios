import SwiftUI

public func floatingButton(image: String, color: Color = .accentColor, action: @escaping () -> Void) -> some View {
	Button(action: action) {
		SwiftUI.Image(systemName: image)
			.font(.system(size: 22, weight: .bold))
			.foregroundColor(.white)
			.frame(width: 60, height: 60)
			.background(color)
			.clipShape(Circle())
			.shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 0)
	}
}

public func textButton(_ title: String, action: @escaping () -> Void) -> some View {
	Button(title, action: action).font(.system(size: 14))
}

public func linkButton(_ title: String, action: @escaping () -> Void) -> some View {
	Button(action: action) {
		Text(title)
			.font(.system(size: 14))
			.foregroundColor(Color(.systemBlue))
			.underline()
			.multilineTextAlignment(.leading)
	}
}

public func actionButton(_ title: String, image: String? = nil, color: Color = Color(.systemBlue), action: @escaping () -> Void) -> some View {
	Button(action: action) {
		HStack(spacing: 6) {
			if let image = image {
				Image(systemName: image)
					.font(.system(size: 15, weight: .medium))
			}
			Text(title)
				.font(.system(size: 15, weight: .medium))
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, 12)
	}
	.background(color)
	.foregroundColor(.white)
	.cornerRadius(8)
}

public func warningButton(_ title: String, image: String? = nil, action: @escaping () -> Void) -> some View {
	actionButton(title, image: image, color: Color(.systemOrange), action: action)
}

public func dangerButton(_ title: String, image: String? = nil, action: @escaping () -> Void) -> some View {
	actionButton(title, image: image, color: Color(.systemRed), action: action)
}

public func successButton(_ title: String, image: String? = nil, action: @escaping () -> Void) -> some View {
	actionButton(title, image: image, color: Color(.systemGreen), action: action)
}