import SwiftUI
import AVFoundation

public struct CameraPreviewView: UIViewRepresentable {
	public let session: AVCaptureSession?

	public init(session: AVCaptureSession?) {
		self.session = session
	}

	public func makeUIView(context: Context) -> UIView {
		let view = UIView()
		view.backgroundColor = .black
		guard let session else { return view }
		let previewLayer = AVCaptureVideoPreviewLayer(session: session)
		previewLayer.videoGravity = .resizeAspectFill
		view.layer.addSublayer(previewLayer)
		return view
	}

	public func updateUIView(_ uiView: UIView, context: Context) {
		guard let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer else { return }
		previewLayer.frame = uiView.bounds
	}
}