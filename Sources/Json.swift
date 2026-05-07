import Foundation

/*
 * Utility class for safely extracting typed values from untyped JSON dictionaries.
 */
public class Json {

	/*
	 * Encodes an Encodable value to a JSON string.
	 * Returns nil if encoding fails.
	 */
	public static func encode(_ value: Encodable) -> String? {
		let jsonEncoder = JSONEncoder();
		if let jsonData = try? jsonEncoder.encode(value) {
			return String(data: jsonData, encoding: .utf8) ?? nil;
		}
		return nil;
	}

	/* Returns true if the value is nil or NSNull. */
	public static func isNull(_ value: Any?) -> Bool {
		return value == nil || value as? NSNull == NSNull();
	}

	/* Returns true if the value is nil, NSNull, or an empty string. */
	public static func isNullOrIsEmpty(_ value: Any?) -> Bool {
		return isNull(value) || (value as? String) == "";
	}

	/*
	 * Returns the value as a String, or defaultValue if null/empty.
	 * The caller must ensure the value is actually a String; otherwise a runtime crash will occur.
	 */
	public static func getString(_ value: Any?, defaultValue: String = "") -> String {
		return !Json.isNullOrIsEmpty(value) ? value as! String : defaultValue;
	}
	/* Returns the value as a String, or nil if null/empty. */
	public static func getStringOrNull(_ value: Any?) -> String? {
		return !Json.isNullOrIsEmpty(value) ? value as? String : nil;
	}

	/*
	 * Returns the value as a [String: String] dictionary, or an empty dictionary if null/empty.
	 * The caller must ensure the value is actually [String: String].
	 */
	public static func getStringList(_ value: Any?, defaultValue: String = "") -> [String: String] {
		return !Json.isNullOrIsEmpty(value) ? value as! [String: String] : [:];
	}

	/*
	 * Returns the value as an Int, or defaultValue if null.
	 * The caller must ensure the value is actually an Int; otherwise a runtime crash will occur.
	 */
	public static func getInt(_ value: Any?, defaultValue: Int = 0) -> Int {
		return !Json.isNull(value) ? value as! Int : defaultValue;
	}
	/* Returns the value as an Int, or nil if null. */
	public static func getIntOrNull(_ value: Any?) -> Int? {
		return !Json.isNull(value) ? value as? Int : nil;
	}

	/*
	 * Returns the value as a Double, or defaultValue if null.
	 * The caller must ensure the value is actually a Double; otherwise a runtime crash will occur.
	 */
	public static func getDouble(_ value: Any?, defaultValue: Double = 0) -> Double {
		return !Json.isNull(value) ? value as! Double : defaultValue;
	}
	/* Returns the value as a Double, or nil if null. */
	public static func getDoubleOrNull(_ value: Any?) -> Double? {
		return !Json.isNull(value) ? value as? Double : nil;
	}

	/*
	 * Returns the value as a Bool, or defaultValue if null.
	 * The caller must ensure the value is actually a Bool; otherwise a runtime crash will occur.
	 */
	public static func getBoolean(_ value: Any?, defaultValue: Bool = false) -> Bool {
		return !Json.isNull(value) ? value as! Bool : defaultValue;
	}

	/*
	 * Converts a Unix timestamp (Double) to a Date.
	 * The caller must ensure the value is a non-null Double.
	 */
	public static func getDateTime(_ value: Any?) -> Date {
		return Timestamp.getNSDate(value as! Double);
	}
	/* Returns the Unix timestamp as a Date, or nil if the value is null. */
	public static func getDateTimeOrNull(_ value: Any?) -> Date? {
		return !Json.isNull(value) ? Timestamp.getNSDate(value as! Double) : nil;
	}
}