import SwiftUI

/*
 * Displays an image loaded asynchronously from a URL. Shows a progress indicator while loading.
 */
public struct RemotePhotoView: View {
	private let url: URL
	private let maxHeight: CGFloat
	private let contentMode: ContentMode

	public init(_ url: URL, maxHeight: CGFloat = 200, contentMode: ContentMode = .fit) {
		self.url = url
		self.maxHeight = maxHeight
		self.contentMode = contentMode
	}

	public var body: some View {
		AsyncImage(url: url) { phase in
			if let image = phase.image {
				image
					.resizable()
					.aspectRatio(contentMode: contentMode)
					.frame(maxHeight: maxHeight)
					.cornerRadius(8)
			} else {
				ProgressView()
					.frame(maxWidth: .infinity)
			}
		}
	}
}