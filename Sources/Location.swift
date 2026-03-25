import Foundation
import MapKit
import Contacts

/*
 * Utility class for location and address helpers.
 */
class Location {

	/*
	 * Returns the localized country name for a given ISO 3166-1 alpha-2 country code.
	 * Always uses the "en_US" locale regardless of device language.
	 *
	 * @param countryCode A two-letter country code (e.g. "FR", "US").
	 * @return The English country name, or nil if the code is unrecognized.
	 */
	static func getCountryNameFromCountryCode(_ countryCode: String) -> String? {
		let current = Locale(identifier: "en_US")
		return current.localizedString(forRegionCode: countryCode)
	}

	/*
	 * Parses a "latitude,longitude" string into a CLLocationCoordinate2D.
	 * Returns nil if the string is empty or does not contain exactly two comma-separated components.
	 *
	 * @param coordinates A string in "lat,lon" format.
	 * @return The parsed coordinate, or nil if the format is invalid.
	 */
	static func getCLLocationCoordinate(_ coordinates: String) -> CLLocationCoordinate2D? {
		if (coordinates == "") {
			return nil;
		}
		let arrayCoord = coordinates.components(separatedBy: ",");
		guard arrayCoord.count >= 2 else {
			return nil;
		}
		return CLLocationCoordinate2D(latitude: Double(arrayCoord[0]) ?? 0, longitude: Double(arrayCoord[1]) ?? 0);
	}

	/*
	 * Returns a formatted address string from a CLPlacemark using CNPostalAddressFormatter.
	 * Returns nil if the placemark has no postal address.
	 *
	 * @param placemark The placemark to format.
	 * @return A formatted multi-line address string, or nil.
	 */
	static func getFormattedAddress(_ placemark: CLPlacemark) -> String? {
		let formatter = CNPostalAddressFormatter();
		guard let postalAddress = placemark.postalAddress else {
			return nil;
		}
		return formatter.string(from: postalAddress);
	}

}