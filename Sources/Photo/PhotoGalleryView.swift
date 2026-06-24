import SwiftUI

/*
 * Horizontal scrollable photo gallery loaded from URLs.
 * Tapping a thumbnail opens it fullscreen in a sheet.
 */
public struct PhotoGalleryView: View {
	private let urls: [URL]
	private let thumbnailSize: CGFloat

	@State private var fullscreenUrl: URL? = nil

	public init(_ urls: [URL], thumbnailSize: CGFloat = 160) {
		self.urls = urls
		self.thumbnailSize = thumbnailSize
	}

	public var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 8) {
				ForEach(Array(urls.enumerated()), id: \.offset) { _, url in
					AsyncImage(url: url) { phase in
						if let image = phase.image {
							image
								.resizable()
								.scaledToFill()
								.frame(width: thumbnailSize, height: thumbnailSize)
								.clipped()
								.cornerRadius(8)
								.onTapGesture {
									fullscreenUrl = url
								}
						} else {
							Color(.systemGray5)
								.frame(width: thumbnailSize, height: thumbnailSize)
								.cornerRadius(8)
						}
					}
				}
			}
		}
		.sheet(isPresented: Binding(
			get: { fullscreenUrl != nil },
			set: { if !$0 { fullscreenUrl = nil } }
		)) {
			if let url = fullscreenUrl {
				AsyncImage(url: url) { phase in
					if let image = phase.image {
						image.resizable().scaledToFit()
					} else {
						ProgressView()
					}
				}
				.ignoresSafeArea()
			}
		}
	}
}