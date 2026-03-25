import Foundation
import MapKit

/*
 * Utility class for MapKit helpers: opening Maps, building regions and annotations.
 */
class Maps {

	/*
	 * Opens the Maps app centered on the given coordinates.
	 *
	 * @param coordinates A "lat,lon" string.
	 * @param placeName   Optional label displayed on the map pin.
	 */
	static func openMap(_ coordinates: String, placeName: String? = nil) {
		let coordinatesData = coordinates.components(separatedBy:",");
		let coordinates = CLLocationCoordinate2DMake(Double(coordinatesData[0]) ?? 0, Double(coordinatesData[1]) ?? 0);
		let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: 1000, longitudinalMeters: 1000);
		let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil);
		let mapItem = MKMapItem(placemark: placemark);
		mapItem.name = placeName ?? "";
		mapItem.openInMaps(launchOptions:[MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center)] as [String : Any]);
	}

	/*
	 * Returns a MKCoordinateRegion centered on the given coordinates with a 0.1° span.
	 * Returns nil if the coordinate string is invalid.
	 *
	 * @param coordinates A "lat,lon" string.
	 */
	static func getMapRegion(coordinates: String) -> MKCoordinateRegion? {
		guard let coord = Location.getCLLocationCoordinate(coordinates) else {
			return nil
		};
		let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1);
		return MKCoordinateRegion(center: coord, span: span);
	}

	/*
	 * Returns an MKPointAnnotation for the given coordinates.
	 * Returns nil if the coordinate string is invalid.
	 *
	 * @param coordinates A "lat,lon" string.
	 * @param title       Optional annotation title.
	 */
	static func getMapAnnotation(coordinates: String, title: String?=nil) -> MKPointAnnotation? {
		guard let coord = Location.getCLLocationCoordinate(coordinates) else {
			return nil
		};
		let annotation = MKPointAnnotation();
		annotation.coordinate = coord;
		annotation.title = title;
		return annotation;
	}

	/*
	 * Sets the visible region of a MKMapView to the given coordinates.
	 * Does nothing if the coordinate string is invalid.
	 *
	 * @param mapView     The map view to update.
	 * @param coordinates A "lat,lon" string.
	 */
	static func setRegion(mapView: MKMapView, coordinates: String) -> Void {
		guard let region = self.getMapRegion(coordinates: coordinates) else {
			return;
		}
		mapView.setRegion(region, animated: true);
	}

	/*
	 * Adds a pin annotation to a MKMapView at the given coordinates.
	 * Does nothing if the coordinate string is invalid.
	 *
	 * @param mapView     The map view to annotate.
	 * @param coordinates A "lat,lon" string.
	 * @param title       Optional annotation title.
	 */
	static func addAnnotation(mapView: MKMapView, coordinates: String, title: String?=nil) -> Void {
		guard let annotation = self.getMapAnnotation(coordinates: coordinates, title: title) else {
			return;
		}

		mapView.addAnnotation(annotation);
	}
}