import SwiftUI
import UIKit

public struct CameraPickerView: UIViewControllerRepresentable {
	@Binding private var image: UIImage?
	@Environment(\.dismiss) private var dismiss
	private let allowsEditing: Bool

	public init(image: Binding<UIImage?>, allowsEditing: Bool = true) {
		self._image = image
		self.allowsEditing = allowsEditing
	}

	public func makeCoordinator() -> Coordinator { Coordinator(self) }

	public func makeUIViewController(context: Context) -> UIImagePickerController {
		let vc = UIImagePickerController()
		vc.sourceType = .camera
		vc.allowsEditing = allowsEditing
		vc.delegate = context.coordinator
		return vc
	}

	public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

	public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
		let parent: CameraPickerView
		init(_ parent: CameraPickerView) { self.parent = parent }

		public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
			let key: UIImagePickerController.InfoKey = parent.allowsEditing ? .editedImage : .originalImage
			if var img = info[key] as? UIImage {
				let data = img.compress(to: 500)
				if !data.isEmpty, let compressed = UIImage(data: data) { img = compressed }
				parent.image = img
			}
			parent.dismiss()
		}

		public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
			parent.dismiss()
		}
	}
}