import SwiftUI
import UIKit
import AVFoundation

public struct CameraPreviewView: UIViewRepresentable {
	public let session: AVCaptureSession?

	public init(session: AVCaptureSession?) {
		self.session = session
	}

	public func makeUIView(context: Context) -> PreviewContainerView {
		let view = PreviewContainerView()
		view.backgroundColor = .black
		if let session {
			view.attachSession(session)
		}
		return view
	}

	public func updateUIView(_ uiView: PreviewContainerView, context: Context) {
		if let session, uiView.previewLayer == nil {
			uiView.attachSession(session)
		}
		uiView.previewLayer?.frame = uiView.bounds
	}
}

public final class PreviewContainerView: UIView {
	var previewLayer: AVCaptureVideoPreviewLayer?

	func attachSession(_ session: AVCaptureSession) {
		let layer = AVCaptureVideoPreviewLayer(session: session)
		layer.videoGravity = .resizeAspectFill
		layer.frame = bounds
		self.layer.addSublayer(layer)
		previewLayer = layer
	}

	public override func layoutSubviews() {
		super.layoutSubviews()
		previewLayer?.frame = bounds
	}
}