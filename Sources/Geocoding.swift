import Foundation
import CoreLocation

/*
 * Utility class for forward and reverse geocoding using CLGeocoder.
 */
class Geocoding {

	/*
	 * Converts a human-readable address string into a CLLocation (forward geocoding).
	 *
	 * @param address   The address string to geocode.
	 * @param onSuccess Called with the resolved CLLocation on success.
	 * @param onError   Called with an error if geocoding fails or no location is found.
	 */
	static func forwardGeocoding(_ address: String, onSuccess: @escaping(CLLocation) -> Void, onError: @escaping(Error?) -> Void) {
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
			if error != nil {
				NSLog("Failed to retrieve location");
				onError(error);
				return;
			}

			guard let placemarks = placemarks, placemarks.count > 0, let location = placemarks.first?.location else {
				NSLog("No Matching Location Found");
				onError(NSError(domain:"No Matching Location Found", code: 402, userInfo:nil));
				return;
			}

			NSLog("\nlat: \(location.coordinate.latitude), long: \(location.coordinate.longitude)");
			onSuccess(location);
		});
	}

	/*
	 * Converts a CLLocation into a postal address (reverse geocoding).
	 *
	 * @param location  The location to reverse-geocode.
	 * @param onSuccess Called with the resolved CLPlacemark on success.
	 * @param onError   Called with an error if geocoding fails or no address is found.
	 */
	static func reverseGeocoding(_ location: CLLocation, onSuccess: @escaping(CLPlacemark) -> Void, onError: @escaping(Error?) -> Void) {
		self.reverseGeocoding(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, onSuccess: onSuccess, onError: onError);
	}

	/*
	 * Converts a latitude/longitude pair into a postal address (reverse geocoding).
	 *
	 * @param latitude  The latitude of the location.
	 * @param longitude The longitude of the location.
	 * @param onSuccess Called with the resolved CLPlacemark on success.
	 * @param onError   Called with an error if geocoding fails or no address is found.
	 */
	static func reverseGeocoding(latitude: CLLocationDegrees, longitude: CLLocationDegrees, onSuccess: @escaping(CLPlacemark) -> Void, onError: @escaping(Error?) -> Void) {
		let geocoder = CLGeocoder();
		let location = CLLocation(latitude: latitude, longitude: longitude)
		geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
			if error != nil {
				NSLog("Failed to retrieve address");
				onError(error);
				return;
			}

			guard let placemarks = placemarks, let placemark = placemarks.first else {
				NSLog("No Matching Address Found");
				onError(NSError(domain:"No Matching Address Found", code: 402, userInfo:nil));
				return;
			}

			NSLog("Address found: %@", placemark.name ?? "<empty>");
			onSuccess(placemark);
		})
	}
}