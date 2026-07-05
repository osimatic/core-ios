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

		Alert.display(title: NFC.errorTitle, message: NFC.errorMessage(from: readerError), viewController: self, goBack: true)
	}

	public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
		guard let payload = NFC.getPayload(messages) else { return }

		nfcSuccess = true
		self.session.invalidate()
		playBeepSound()

		DispatchQueue.main.async {
			self.onScan?(payload.url, payload.byApp)
		}
	}

	// MARK: - NFC session

	private func beginSession() {
		nfcSuccess = false
		session = NFC.beginSession(delegate: self)
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