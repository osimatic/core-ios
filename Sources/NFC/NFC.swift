import Foundation
import CoreNFC

public class NFC {

	// MARK: - Configurable messages

	public static var errorTitle: String = "Error"
	public static var errorMessageUnsupportedFeature: String = "NFC unsupported"
	public static var errorMessageSessionTimeout: String = "NFC session timeout"
	public static var errorMessageUnknown: String = "NFC error"

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
				return errorMessageUnsupportedFeature
			case .readerSessionInvalidationErrorSessionTimeout:
				return errorMessageSessionTimeout
			default:
				return errorMessageUnknown
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