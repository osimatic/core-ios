import SwiftUI
import UIKit

public struct PhotoView: View {
	private let image: UIImage
	private let maxHeight: CGFloat

	public init(_ image: UIImage, maxHeight: CGFloat = 200) {
		self.image = image
		self.maxHeight = maxHeight
	}

	public var body: some View {
		SwiftUI.Image(uiImage: image)
			.resizable()
			.scaledToFit()
			.frame(maxHeight: maxHeight)
			.cornerRadius(8)
	}
}