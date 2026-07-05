import Foundation
import CoreNFC

public class NFC {

	// MARK: - Configurable messages

	public static var errorTitle: String = "Error"
	public static var tagReadErrorMessageUnsupportedFeature: String = "NFC unsupported"
	public static var tagReadErrorMessageSessionTimeout: String = "NFC session timeout"
	public static var tagReadErrorMessageUnknown: String = "NFC error"

	public static var tagWriteSuccessMessage: String = "Success"
	public static var tagWriteErrorConnectionFailed: String = "Connection failed"
	public static var tagWriteErrorTagNotSupported: String = "Tag not supported"
	public static var tagWriteErrorTagOnlyReadable: String = "Tag is read only"
	public static var tagWriteErrorUnknown: String = "Unknown error"

	// MARK: - Session

	public static func beginSession(delegate: NFCNDEFReaderSessionDelegate) -> NFCNDEFReaderSession {
		let session = NFCNDEFReaderSession(delegate: delegate, queue: DispatchQueue.main, invalidateAfterFirstRead: false)
		session.begin()
		return session
	}

	// MARK: - Error

	public static func errorMessage(from error: NFCReaderError) -> String {
		switch error.code {
			case .readerErrorUnsupportedFeature:
				return tagReadErrorMessageUnsupportedFeature
			case .readerSessionInvalidationErrorSessionTimeout:
				return tagReadErrorMessageSessionTimeout
			default:
				return tagReadErrorMessageUnknown
		}
	}

	// MARK: - Tag writing

	public static func writeTag(_ tag: NFCNDEFTag, message: NFCNDEFMessage, session: NFCNDEFReaderSession, onSuccess: @escaping () -> Void) {
		tag.queryNDEFStatus { status, _, error in
			guard error == nil else {
				session.invalidate(errorMessage: NFC.tagWriteErrorConnectionFailed)
				return
			}
			if status == .notSupported {
				session.invalidate(errorMessage: NFC.tagWriteErrorTagNotSupported)
				return
			}
			if status == .readOnly {
				session.invalidate(errorMessage: NFC.tagWriteErrorTagOnlyReadable)
				return
			}
			if status != .readWrite {
				session.invalidate(errorMessage: NFC.tagWriteErrorUnknown)
				return
			}
			tag.writeNDEF(message) { error in
				if error != nil {
					session.invalidate(errorMessage: NFC.tagWriteErrorUnknown)
				} else {
					onSuccess()
					session.alertMessage = NFC.tagWriteSuccessMessage
					session.invalidate()
				}
			}
		}
	}

	// MARK: - Payload parsing

	public static func getPayload(_ messages: [NFCNDEFMessage]) -> (url: String, byApp: Bool)? {
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
						return (url: uriPayload.absoluteString, byApp: false)
					}
				} else {
					if let metadata = String(data: payload.payload, encoding: .utf8) {
						NSLog("byApp. payload : %@", metadata)
						return (url: metadata, byApp: true)
					}
				}
			}
		}
		NSLog("returned nil")
		return nil
	}
}