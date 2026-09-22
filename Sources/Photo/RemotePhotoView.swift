import SwiftUI

/*
 * Displays an image loaded asynchronously from a URL. Shows a progress indicator while loading.
 */
public struct RemotePhotoView: View {
	private let url: URL
	private let maxHeight: CGFloat

	public init(_ url: URL, maxHeight: CGFloat = 200) {
		self.url = url
		self.maxHeight = maxHeight
	}

	public var body: some View {
		AsyncImage(url: url) { phase in
			if let image = phase.image {
				image
					.resizable()
					.scaledToFit()
					.frame(maxHeight: maxHeight)
					.cornerRadius(8)
			} else {
				ProgressView()
					.frame(maxWidth: .infinity)
			}
		}
	}
}