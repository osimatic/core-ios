import Foundation

/*
 * Utility class for accessing application-level information.
 */
public class App {

	/*
	 * Returns the current app version string (CFBundleShortVersionString).
	 * Returns an empty string if the key is missing from the bundle info dictionary.
	 */
	public static func getAppVersion() -> String {
		return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "";
	}

}