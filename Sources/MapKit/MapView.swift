import SwiftUI
import MapKit
import CoreLocation

public struct MapView: UIViewRepresentable {
	private let coordinates: String?
	private let annotationTitle: String?
	private let location: CLLocation?

	public init(coordinates: String, annotationTitle: String) {
		self.coordinates = coordinates
		self.annotationTitle = annotationTitle
		self.location = nil
	}

	public init(location: CLLocation?) {
		self.location = location
		self.coordinates = nil
		self.annotationTitle = nil
	}

	public func makeUIView(context: Context) -> MKMapView {
		let map = MKMapView()
		if let coords = coordinates {
			Maps.setRegion(mapView: map, coordinates: coords)
			if let title = annotationTitle {
				Maps.addAnnotation(mapView: map, coordinates: coords, title: title)
			}
		}
		return map
	}

	public func updateUIView(_ uiView: MKMapView, context: Context) {
		guard let loc = location else { return }
		let camera = MKMapCamera(lookingAtCenter: loc.coordinate, fromEyeCoordinate: loc.coordinate, eyeAltitude: 1000)
		uiView.setCamera(camera, animated: true)
	}
}