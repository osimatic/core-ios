import SwiftUI
import UIKit
import AVFoundation
import CoreNFC

// MARK: - ViewModel

public class NFCScanViewModel: ObservableObject {
	@Published public var isLoading = false

	public init() {}
}

// MARK: - View

public struct NFCScanView: View {
	@ObservedObject var viewModel: NFCScanViewModel
	let backgroundColor: Color

	public init(viewModel: NFCScanViewModel, backgroundColor: Color = Color(UIColor.systemBackground)) {
		self.viewModel = viewModel
		self.backgroundColor = backgroundColor
	}

	public var body: some View {
		backgroundColor.ignoresSafeArea()
			.overlay {
				if viewModel.isLoading {
					ProgressView().scaleEffect(1.5)
				}
			}
	}
}

// MARK: - Hosting controller

open class NFCScanViewController: UIHostingController<NFCScanView>, NFCNDEFReaderSessionDelegate {

	public var onScan: ((String, Bool) -> Void)?
	public var scanBackgroundColor: Color = Color(UIColor.systemBackground)
	public var errorTitle: String = "Error"
	public var errorMessageUnsupportedFeature: String = "NFC unsupported"
	public var errorMessageSessionTimeout: String = "NFC session timeout"
	public var errorMessageUnknown: String = "NFC error"

	private var nfcSuccess = false
	private var session: NFCNDEFReaderSession!
	private var audioPlayer: AVAudioPlayer?
	public let viewModel = NFCScanViewModel()

	public init() {
		super.init(rootView: NFCScanView(viewModel: NFCScanViewModel()))
	}

	@MainActor required dynamic public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	open override func viewDidLoad() {
		super.viewDidLoad()
		view.layer.drawsAsynchronously = false
		loadBeepSound()
		rootView = NFCScanView(viewModel: viewModel, backgroundColor: scanBackgroundColor)
	}

	open override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	open override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		beginSession()
	}

	// MARK: - NFCNDEFReaderSessionDelegate

	public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
		NSLog("Error: %@", error.localizedDescription)

		guard let readerError = error as? NFCReaderError else { return }
		if readerError.code == NFCReaderError.readerSessionInvalidationErrorUserCanceled {
			DispatchQueue.main.async {
				if !self.nfcSuccess {
					self.navigationController?.popViewController(animated: true)
				}
			}
			return
		}

		Alert.display(title: errorTitle, message: errorMessage(from: readerError), viewController: self, goBack: true)
	}

	public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
		guard let payload = getPayload(messages) else { return }

		nfcSuccess = true
		self.session.invalidate()
		playBeepSound()

		DispatchQueue.main.async {
			self.onScan?(payload.url, payload.byApp)
		}
	}

	// MARK: - Error message

	open func errorMessage(from error: NFCReaderError) -> String {
		switch error.code {
			case .readerErrorUnsupportedFeature:
				return errorMessageUnsupportedFeature
			case .readerSessionInvalidationErrorSessionTimeout:
				return errorMessageSessionTimeout
			default:
				return errorMessageUnknown
		}
	}

	// MARK: - NFC session

	private func beginSession() {
		nfcSuccess = false
		session = NFCNDEFReaderSession(delegate: self, queue: DispatchQueue.main, invalidateAfterFirstRead: false)
		session.begin()
	}

	// MARK: - Payload parsing

	private struct NFCPayload {
		let url: String
		let byApp: Bool
	}

	private func getPayload(_ messages: [NFCNDEFMessage]) -> NFCPayload? {
		for message in messages {
			for payload in message.records {
				NSLog("Identifier: %@ (%@) ; Type: %@ (%@) ; Format: %d ; Payload: %@ (%@)",
					payload.identifier.description, String(data: payload.identifier, encoding: .ascii) ?? "",
					payload.type.description, String(data: payload.type, encoding: .ascii) ?? "",
					payload.typeNameFormat.rawValue,
					payload.payload.description, String(data: payload.payload, encoding: .ascii) ?? ""
				)

				if payload.typeNameFormat == .nfcWellKnown {
					if let uriPayload = payload.wellKnownTypeURIPayload(), uriPayload.absoluteString != "" {
						NSLog("URI. payload : %@", uriPayload.absoluteString)
						return NFCPayload(url: uriPayload.absoluteString, byApp: false)
					}
				} else {
					if let metadata = String(data: payload.payload, encoding: .utf8) {
						NSLog("byApp. payload : %@", metadata)
						return NFCPayload(url: metadata, byApp: true)
					}
				}
			}
		}
		NSLog("returned nil")
		return nil
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