import Foundation;
import UIKit;

/* Returns true if the current iOS version equals the given version string. */
func SYSTEM_VERSION_EQUAL_TO(v: String) -> Bool {
	return UIDevice.current.systemVersion.compare(v, options: String.CompareOptions.numeric, range: nil, locale: nil) == ComparisonResult.orderedSame;
}
/* Returns true if the current iOS version is strictly greater than the given version string. */
func SYSTEM_VERSION_GREATER_THAN(v: String) -> Bool {
	return UIDevice.current.systemVersion.compare(v, options: String.CompareOptions.numeric, range: nil, locale: nil) == ComparisonResult.orderedDescending;
}
/* Returns true if the current iOS version is greater than or equal to the given version string. */
func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v: String) -> Bool {
	return UIDevice.current.systemVersion.compare(v, options: String.CompareOptions.numeric, range: nil, locale: nil) != ComparisonResult.orderedAscending;
}
/* Returns true if the current iOS version is strictly less than the given version string. */
func SYSTEM_VERSION_LESS_THAN(v: String) -> Bool {
	return UIDevice.current.systemVersion.compare(v, options: String.CompareOptions.numeric, range: nil, locale: nil) == ComparisonResult.orderedAscending;
}
/* Returns true if the current iOS version is less than or equal to the given version string. */
func SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v: String) -> Bool {
	return UIDevice.current.systemVersion.compare(v, options: String.CompareOptions.numeric, range: nil, locale: nil) != ComparisonResult.orderedDescending;
}

/*
 * Utility class for accessing device information.
 */
class Device {
	static var udid : String? = nil;

	/*
	 * Returns the device UUID (identifierForVendor).
	 * The value is cached after the first call.
	 * Returns an empty string if the identifier is unavailable.
	 */
	static func getUUID() -> String {
		if (udid == nil) {
			udid = UIDevice.current.identifierForVendor?.uuidString;
		}
		return udid ?? "";
	}

	/* Returns the device model name (e.g. "iPhone", "iPad"). */
	static func getName() -> String {
		return UIDevice.current.model;
	}

	/* Returns the OS name (e.g. "iOS"). */
	static func getOsName() -> String {
		return UIDevice.current.systemName;
	}
	/* Returns the OS version string (e.g. "17.0"). */
	static func getOsVersion() -> String {
		return UIDevice.current.systemVersion;
	}

	/* Returns true if the device is an iPhone. */
	static func isPhone() -> Bool {
		return UIDevice.current.userInterfaceIdiom == .phone;
	}
	/* Returns true if the device is an iPad. */
	static func isPad() -> Bool {
		return UIDevice.current.userInterfaceIdiom == .pad;
	}
	/* Returns true if the device is an Apple TV. */
	static func isTV() -> Bool {
		return UIDevice.current.userInterfaceIdiom == .tv;
	}
	/* Returns true if the device is running in CarPlay. */
	static func isCarPlay() -> Bool {
		return UIDevice.current.userInterfaceIdiom == .carPlay;
	}

	/*static func isDarkMode() -> Bool {
		return traitCollection.userInterfaceStyle == .dark;
	}*/

}