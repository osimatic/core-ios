import SwiftUI
import UIKit

public struct SinglePhotoPickerView: View {
    @Binding var photo: UIImage?
    let label: String

    @State private var showCamera = false

    public init(photo: Binding<UIImage?>, label: String = "Add a photo") {
        self._photo = photo
        self.label = label
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let img = photo {
                PhotoView(img)
            }
            Button(action: { showCamera = true }) {
                Label(label, systemImage: "camera")
                    .font(.system(size: 14))
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraPickerView(image: $photo)
        }
    }
}
