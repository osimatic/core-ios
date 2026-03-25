import Foundation
import MapKit
import CoreLocation

extension CLPlacemark {
	
	var fullLocationAddress: String {
		// MARK: Get the same address, that could be provided by Google Places API
		// https://developers.google.com/maps/documentation/javascript/examples/places-autocomplete
		var placemarkData: [String] = []
		
		if let area = areasOfInterest?.first { placemarkData.append(area.localizedCapitalized) }
		if let street = thoroughfare?.localizedCapitalized { placemarkData.append(street) }
		if let building = subThoroughfare?.localizedCapitalized { placemarkData.append(building)}
		if let city = locality?.localizedCapitalized { placemarkData.append(city) }
		if let subCity = subLocality?.localizedCapitalized { placemarkData.append(subCity) }
		if let state = administrativeArea?.localizedCapitalized { placemarkData.append(state) }
		if let stateArea = subAdministrativeArea?.localizedCapitalized { placemarkData.append(stateArea) }
		if let county = country?.localizedCapitalized { placemarkData.append(county) }
		
		var result = ""
		
		placemarkData.forEach { result.append(" "+$0+",") }
		result = result.trimmingCharacters(in: .whitespacesAndNewlines)
		result.removeLast() // remove last comma
		
		return result
	}
}
