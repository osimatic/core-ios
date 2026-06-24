import SwiftUI
import UIKit

/*
 * Grid of captured photos (3 columns) with a delete button on each thumbnail
 * and an "Add photo" button that opens the camera.
 * Camera state is managed internally. The caller provides the photos array
 * and responds to add/remove events via callbacks.
 */
public struct PhotoGridPickerView: View {
	let photos: [UIImage]
	let maxPhotos: Int
	let addLabel: String
	let onAdd: (UIImage) -> Void
	let onRemove: (Int) -> Void

	@State private var showCamera = false
	@State private var newPhoto: UIImage? = nil

	private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

	public init(
		photos: [UIImage],
		maxPhotos: Int = 5,
		addLabel: String = "Add a photo",
		onAdd: @escaping (UIImage) -> Void,
		onRemove: @escaping (Int) -> Void
	) {
		self.photos = photos
		self.maxPhotos = maxPhotos
		self.addLabel = addLabel
		self.onAdd = onAdd
		self.onRemove = onRemove
	}

	public var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			if (!photos.isEmpty) {
				LazyVGrid(columns: columns, spacing: 8) {
					ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
						ZStack(alignment: .topTrailing) {
							SwiftUI.Image(uiImage: photo)
								.resizable()
								.scaledToFill()
								.frame(maxWidth: .infinity)
								.aspectRatio(1, contentMode: .fill)
								.clipped()
								.cornerRadius(8)
							Button(action: { onRemove(index) }) {
								SwiftUI.Image(systemName: "xmark.circle.fill")
									.font(.system(size: 20))
									.foregroundColor(.white)
									.shadow(color: .black.opacity(0.4), radius: 2)
							}
							.padding(4)
						}
					}
				}
			}

			if (photos.count < maxPhotos) {
				Button(action: { showCamera = true }) {
					Label(addLabel, systemImage: "camera")
						.font(.system(size: 14))
				}
			}
		}
		.sheet(isPresented: $showCamera) {
			CameraPickerView(image: $newPhoto)
		}
		.onChange(of: newPhoto) { photo in
			if let photo = photo {
				onAdd(photo)
				newPhoto = nil
			}
		}
	}
}