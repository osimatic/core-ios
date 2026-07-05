import SwiftUI
import UIKit
import AVFoundation

// MARK: - ViewModel

public class QRCodeScanViewModel: ObservableObject {
	@Published public var isScanning = false
	@Published public var isLoading = false

	public init() {}
}

// MARK: - View

public struct QRCodeScanView: View {
	@ObservedObject var viewModel: QRCodeScanViewModel
	let captureSession: AVCaptureSession?
	let onStartStop: () -> Void
	let onSwitchCamera: () -> Void
	let startScanningLabel: String
	let stopScanningLabel: String

	public init(viewModel: QRCodeScanViewModel, captureSession: AVCaptureSession?, onStartStop: @escaping () -> Void, onSwitchCamera: @escaping () -> Void, startScanningLabel: String, stopScanningLabel: String) {
		self.viewModel = viewModel
		self.captureSession = captureSession
		self.onStartStop = onStartStop
		self.onSwitchCamera = onSwitchCamera
		self.startScanningLabel = startScanningLabel
		self.stopScanningLabel = stopScanningLabel
	}

	public var body: some View {
		ZStack {
			CameraPreviewView(session: captureSession).ignoresSafeArea()
			if viewModel.isLoading {
				Color.black.opacity(0.4).ignoresSafeArea()
				ProgressView().scaleEffect(1.5).tint(.white)
			}
		}
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button(action: onSwitchCamera) {
					Image(systemName: "arrow.triangle.2.circlepath.camera")
				}
			}
			ToolbarItem(placement: .navigationBarTrailing) {
				Button(action: onStartStop) {
					Text(viewModel.isScanning ? stopScanningLabel : startScanningLabel)
				}
			}
		}
	}
}

// MARK: - Hosting controller

open class QRCodeScanViewController: UIHostingController<QRCodeScanView>, AVCaptureMetadataOutputObjectsDelegate {

	public var onScan: ((String) -> Void)?

	public var startScanningLabel: String = "Start"
	public var stopScanningLabel: String = "Stop"
	public var notSupportedTitle: String = "Error"
	public var notSupportedMessage: String = "QR code scanning is not supported on this device."

	private var frontCameraDeviceInput: AVCaptureDeviceInput?
	private var backCameraDeviceInput: AVCaptureDeviceInput?
	private(set) public var captureSession: AVCaptureSession?
	private var audioPlayer: AVAudioPlayer?
	public let viewModel = QRCodeScanViewModel()

	public init() {
		super.init(rootView: QRCodeScanView(
			viewModel: QRCodeScanViewModel(),
			captureSession: nil,
			onStartStop: {},
			onSwitchCamera: {},
			startScanningLabel: "",
			stopScanningLabel: ""
		))
	}

	@MainActor required dynamic public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	open override func viewDidLoad() {
		super.viewDidLoad()
		view.layer.drawsAsynchronously = false
		loadCamera()
		loadBeepSound()
		rootView = QRCodeScanView(
			viewModel: viewModel,
			captureSession: captureSession,
			onStartStop: { [weak self] in self?.startStopReading() },
			onSwitchCamera: { [weak self] in self?.switchCamera() },
			startScanningLabel: startScanningLabel,
			stopScanningLabel: stopScanningLabel
		)
	}

	open override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if captureSession?.isRunning == false {
			startReading()
		}
	}

	open override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if captureSession?.isRunning == true {
			stopReading()
		}
	}

	// MARK: - AVCaptureMetadataOutputObjectsDelegate

	public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
		guard viewModel.isScanning else { return }
		guard let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
			  metadataObj.type == .qr,
			  let stringValue = metadataObj.stringValue else { return }

		stopReading()
		viewModel.isLoading = true
		playBeepSound()
		onScan?(stringValue)
	}

	// MARK: - Camera

	private func loadCamera() {
		let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
		guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
			displayNotSupported()
			return
		}

		if let frontCamera {
			frontCameraDeviceInput = try? AVCaptureDeviceInput(device: frontCamera)
		}
		backCameraDeviceInput = try? AVCaptureDeviceInput(device: backCamera)

		let session = AVCaptureSession()
		guard let backInput = backCameraDeviceInput else {
			displayNotSupported()
			return
		}

		if session.canAddInput(backInput) {
			session.addInput(backInput)
		} else {
			displayNotSupported()
			return
		}

		let captureMetadataOutput = AVCaptureMetadataOutput()
		if session.canAddOutput(captureMetadataOutput) {
			session.addOutput(captureMetadataOutput)
			captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
			captureMetadataOutput.metadataObjectTypes = [.qr]
		} else {
			displayNotSupported()
			return
		}

		captureSession = session
	}

	public func startReading() {
		viewModel.isScanning = true
		captureSession?.startRunning()
	}

	public func stopReading() {
		viewModel.isScanning = false
		captureSession?.stopRunning()
	}

	private func startStopReading() {
		if viewModel.isScanning {
			stopReading()
		} else {
			startReading()
		}
	}

	private func switchCamera() {
		guard let frontInput = frontCameraDeviceInput, let backInput = backCameraDeviceInput else { return }
		captureSession?.beginConfiguration()
		if captureSession?.inputs.contains(frontInput) == true {
			captureSession?.removeInput(frontInput)
			captureSession?.addInput(backInput)
		} else if captureSession?.inputs.contains(backInput) == true {
			captureSession?.removeInput(backInput)
			captureSession?.addInput(frontInput)
		}
		captureSession?.commitConfiguration()
	}

	open func displayNotSupported() {
		Alert.display(title: notSupportedTitle, message: notSupportedMessage, viewController: self, goBack: true)
		captureSession = nil
	}

	// MARK: - Beep

	private func loadBeepSound() {
		audioPlayer = Audio.getPlayer(ressource: "beep", type: "mp3")
		audioPlayer?.prepareToPlay()
	}

	private func playBeepSound() {
		audioPlayer?.play()
	}
}