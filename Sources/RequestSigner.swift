import Foundation
import CryptoKit

/*
 * Signs sensitive HTTP requests using HMAC-SHA256.
 *
 * The secret can be initialized once at app startup:
 *   RequestSigner.setSecret(secret);
 *
 * The server must verify:
 *  - that the signature matches (same secret + same canonical string)
 *  - that X-Timestamp is recent (e.g. ±5 min)
 *  - that X-Nonce has not already been used (anti-replay)
 */
public class RequestSigner {

	/*
	 * Result of a signature: the timestamp, the nonce and the signature, to send as HTTP headers.
	 */
	public struct SignatureResult {
		public let timestamp: String;
		public let nonce: String;
		public let signature: String;

		/*
		 * The 3 headers to include in the HTTP request.
		 */
		public var headers: [String: String] {
			return [
				"X-Timestamp": timestamp,
				"X-Nonce": nonce,
				"X-Signature": signature,
			];
		}
	}

	private static var secret: String = "";

	/*
	 * Initializes the HMAC secret. Must be called once at startup if the secret is not passed to sign().
	 *
	 * @param s The shared secret.
	 */
	public static func setSecret(_ s: String?) {
		secret = s ?? "";
	}

	/*
	 * Signs a set of critical fields.
	 *
	 * Canonical string that is signed:
	 *   timestamp\n
	 *   nonce\n
	 *   field1=value1&field2=value2   (keys sorted alphabetically, no trailing '&')
	 *
	 * @param criticalFields Fields to include in the signature (key → value).
	 * @param secret The shared secret ; if nil, the secret set with setSecret() is used.
	 * @return The SignatureResult containing the 3 headers to add to the request.
	 */
	public static func sign(_ criticalFields: [String: String], secret: String? = nil) -> SignatureResult {
		let timestamp = String(Int(Date().timeIntervalSince1970));
		let nonce = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased();

		let canonical = timestamp + "\n" + nonce + "\n" + criticalFields.keys.sorted().map { key in
			return key + "=" + (criticalFields[key] ?? "");
		}.joined(separator: "&");

		let signature = hmacSha256(secret: secret ?? self.secret, data: canonical);
		return SignatureResult(timestamp: timestamp, nonce: nonce, signature: signature);
	}

	private static func hmacSha256(secret: String, data: String) -> String {
		let key = SymmetricKey(data: Data(secret.utf8));
		let mac = HMAC<SHA256>.authenticationCode(for: Data(data.utf8), using: key);
		return Data(mac).base64EncodedString();
	}
}