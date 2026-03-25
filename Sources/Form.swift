import Foundation

/*
 * Utility class for parsing server-side form validation error responses.
 */
class Form {

	/*
	 * Extracts a human-readable error message from a JSON error value.
	 * Supports String, [String] (index 1 = message), and {error, message} object formats.
	 *
	 * @param json The raw JSON value returned by the server for a field error.
	 * @return The error message string, or nil if none can be extracted.
	 */
	static func getErrorMessage(_ json: Any) -> String? {
		if let json = json as? String {
			return json;
		}

		if let json = json as? [String] {
			return json[1];
		}

		if let errorObject = Form.getErrorJsonObject(json), let errorObject = errorObject as? [String: Any] {
			return Json.getStringOrNull(errorObject["message"]);
		}
		return nil;
	}

	/*
	 * Extracts the error key from a JSON error value.
	 * Supports [String] (index 0 = key) and {error, message} object formats.
	 *
	 * @param json The raw JSON value returned by the server for a field error.
	 * @return The error key string, or nil if none can be extracted.
	 */
	static func getErrorKey(_ json: Any) -> String? {
		if let json = json as? [String] {
			return json[0];
		}

		if let errorObject = Form.getErrorJsonObject(json), let errorObject = errorObject as? [String: Any] {
			return Json.getStringOrNull(errorObject["error"]);
		}
		return nil;
	}

	/*
	 * Returns the first object containing an "error" key from the given JSON value.
	 * Handles both single-object and single-element-array forms.
	 */
	static func getErrorJsonObject(_ json: Any) -> Any? {
		if let json = json as? [String: Any], let _ = json["error"] {
			return json;
		}

		if let json = json as? [[String: Any]], let _ = json[0]["error"], json.count == 1 {
			return json[0];
		}

		return nil;
	}

	/*
	 * Extracts all error messages from a server validation error payload.
	 * Supports [String: Any], [[String]], [String], and [[String: Any]] formats.
	 * Returns defaultErrorMessage (wrapped in an array) if no errors could be parsed.
	 *
	 * @param jsonErrors          The raw JSON errors payload.
	 * @param defaultErrorMessage Fallback message used when the parsed list is empty.
	 * @return An array of non-empty error message strings.
	 */
	static func getListErrors(_ jsonErrors: Any, _ defaultErrorMessage: String? = nil) -> [String] {
		var errorMessages: [String?] = [];

		if let jsonErrors = jsonErrors as? [String: Any] {
			errorMessages = jsonErrors.map({ getErrorMessage($1) });
		}
		if let jsonErrors = jsonErrors as? [[String]] {
			errorMessages = jsonErrors.map({ getErrorMessage($0) });
		}
		if let jsonErrors = jsonErrors as? [String] {
			errorMessages = jsonErrors.map({ getErrorMessage($0) });
		}
		if let jsonErrors = jsonErrors as? [[String: Any]] {
			errorMessages = jsonErrors.map({ getErrorMessage($0) });
		}

		let filteredErrorMessages: [String] = errorMessages.filter({ $0 != nil && !($0 ?? "").isEmpty }) as? [String] ?? [];

		if let defaultErrorMessage = defaultErrorMessage, filteredErrorMessages.isEmpty {
			return [defaultErrorMessage];
		}

		return filteredErrorMessages;
	}

	/*
	 * Joins an array of error messages into a single newline-separated string.
	 */
	static func getErrorMessages(_ errorMessages: [String]) -> String {
		return errorMessages.joined(separator: "\n");
	}

	/*
	 * Returns true if any error key in the payload matches one of the given form field keys.
	 *
	 * @param jsonErrors    The server error payload as a [String: Any] dictionary.
	 * @param formErrorKeys The list of field keys to look for.
	 */
	static func isFormError(_ jsonErrors: [String: Any], _ formErrorKeys: [String] = []) -> Bool {
		for (fieldName, _) in jsonErrors {
			if (formErrorKeys.contains(fieldName)) {
				return true;
			}
		}
		return false;
	}
	static func isFormError(_ jsonErrors: [[String]], _ formErrorKeys: [String] = []) -> Bool {
		for jsonError in jsonErrors {
			if let errorKey = getErrorKey(jsonError), formErrorKeys.contains(errorKey) {
				return true;
			}
		}
		return false;
	}
	static func isFormError(_ jsonErrors: [[String: Any]], _ formErrorKeys: [String] = []) -> Bool {
		for jsonError in jsonErrors {
			if let errorKey = getErrorKey(jsonError), formErrorKeys.contains(errorKey) {
				return true;
			}
		}
		return false;
	}

}