import Foundation

/*
 * Utility class for decoding JSON Web Tokens (JWT).
 */
class JWT {

	/*
	 * Decodes the payload (second segment) of a JWT and returns it as a dictionary.
	 * Throws DecodeErrors.badToken if the token has fewer than 2 segments or the
	 * Base64 padding is invalid, and DecodeErrors.other if the payload is not a JSON object.
	 *
	 * @param jwt The JWT string in "header.payload.signature" format.
	 * @return A dictionary containing the decoded JWT claims.
	 */
	static func parse(_ jwt: String) throws -> [String: Any] {

		enum DecodeErrors: Error {
			case badToken
			case other
		}

		func base64Decode(_ base64: String) throws -> Data {
			let base64 = base64
				.replacingOccurrences(of: "-", with: "+")
				.replacingOccurrences(of: "_", with: "/")
			let padded = base64.padding(toLength: ((base64.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
			guard let decoded = Data(base64Encoded: padded) else {
				throw DecodeErrors.badToken
			}
			return decoded
		}

		func decodeJWTPart(_ value: String) throws -> [String: Any] {
			let bodyData = try base64Decode(value)
			let json = try JSONSerialization.jsonObject(with: bodyData, options: [])
			guard let payload = json as? [String: Any] else {
				throw DecodeErrors.other
			}
			return payload
		}

		let segments = jwt.components(separatedBy: ".")
		guard segments.count >= 2 else {
			throw DecodeErrors.badToken
		}
		return try decodeJWTPart(segments[1])
	}
}