import Foundation

/*
 * Extension on URL for reading individual query parameter values.
 */
extension URL {

	/*
	 * Returns the value of the named query parameter, or nil if not present.
	 *
	 * @param queryParamaterName The query parameter name to look up.
	 */
	func valueOf(_ queryParamaterName: String) -> String? {
		guard let url = URLComponents(string: self.absoluteString) else { return nil }
		return url.valueOf(queryParamaterName);
	}
}

/*
 * Extension on URLComponents for reading individual query parameter values.
 */
extension URLComponents {

	/*
	 * Returns the value of the first query item matching the given name, or nil if not found.
	 *
	 * @param queryParamaterName The query parameter name to look up.
	 */
	func valueOf(_ queryParamaterName: String) -> String? {
		return self.queryItems?.first(where: { $0.name == queryParamaterName })?.value;
	}
}

/*
 * Utility class for building URL query strings from dictionaries.
 */
class URLQueryString {
	var queryString: String;

	/* Initializes the query string directly from a raw string. */
	init(_ queryString: String) {
		self.queryString = queryString;
	}
	/* Initializes the query string by encoding a key-value dictionary. */
	init(array: [String: Any]) {
		self.queryString = URLQueryString.getQueryStringFromArray(array);
	}

	/*
	 * Encodes a [String: Any] dictionary into a percent-encoded query string.
	 * Non-String values are converted via String interpolation before encoding.
	 *
	 * @param queryArray The key-value pairs to encode.
	 * @return A "&"-separated query string (e.g. "key1=val1&key2=val2").
	 */
	static func getQueryStringFromArray(_ queryArray: [String: Any]) -> String {
		var parts: [String] = [];
		for (key, value) in queryArray {
			let stringValue = (value as? String) ?? "\(value)";
			parts.append(String(format:"%@=%@", key, stringValue.urlEncoded()));
		};
		return parts.joined(separator: "&");
	}

}