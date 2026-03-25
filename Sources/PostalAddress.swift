import Foundation

/*
 * Model representing a postal address with optional street, additional address line,
 * postal code, city, and country code.
 */
class PostalAddress {
	var street: String?;
	var additionalAddress: String?;
	var postCode: String?;
	var city: String?;
	var countryCode: String?;

	/*
	 * Initializes a PostalAddress.
	 * countryCode defaults to "FR" if nil is provided.
	 */
	init (street: String?, additionalAddress: String?, postCode: String?, city: String?, countryCode: String?) {
		self.street = street;
		self.additionalAddress = additionalAddress;
		self.postCode = postCode;
		self.city = city;
		self.countryCode = countryCode ?? "FR";
	}

	/*
	 * Returns true if all address fields (street, additionalAddress, postCode, city) are nil.
	 */
	func isEmpty() -> Bool {
		return !(false
			|| nil != self.street
			|| nil != self.additionalAddress
			|| nil != self.postCode
			|| nil != self.city
		);
	}

	/* Returns a formatted string representation of this address. */
	func format(upperCase: Bool = true, separator: String? = nil) -> String {
		return PostalAddress.format(self, upperCase: upperCase, separator: separator);
	}

	/*
	 * Formats a PostalAddress into a multi-line display string.
	 * Empty fields are skipped. The trailing separator is stripped.
	 *
	 * @param postalAddress The address to format.
	 * @param upperCase     If true, all text is uppercased (default: true).
	 * @param separator     The line separator (default: newline).
	 * @return A formatted address string.
	 */
	static func format(_ postalAddress: PostalAddress, upperCase: Bool = true, separator: String? = nil) -> String {
		let separator = separator ?? "\n";

		var addressDisplay = "";

		// Street
		if (postalAddress.street != nil && postalAddress.street != "") {
			addressDisplay += ((upperCase ? postalAddress.street?.uppercased() : postalAddress.street) ?? "") + separator;
		}

		// Additional address line
		if (postalAddress.additionalAddress != nil && postalAddress.additionalAddress != "") {
			addressDisplay += ((upperCase ? postalAddress.additionalAddress?.uppercased() : postalAddress.additionalAddress) ?? "") + separator;
		}

		// Postal code and city
		if ((postalAddress.postCode != nil && postalAddress.postCode != "") || (postalAddress.city != nil && postalAddress.city != "")) {
			var postCode = "";
			if (postalAddress.postCode != nil && postalAddress.postCode != "") {
				postCode = (upperCase ? postalAddress.postCode?.uppercased() : postalAddress.postCode) ?? "";
			}
			var city = "";
			if (postalAddress.city != nil && postalAddress.city != "") {
				city = (upperCase ? postalAddress.city?.uppercased() : postalAddress.city) ?? "";
			}
			addressDisplay += postCode + " " + city + separator;
		}

		// Country
		if (postalAddress.countryCode != nil && postalAddress.countryCode != "") {
			var countryName = Location.getCountryNameFromCountryCode(postalAddress.countryCode ?? "");
			countryName = (upperCase ? countryName?.uppercased() : countryName) ?? "";
			addressDisplay += (countryName ?? "") + separator;
		}

		return String(addressDisplay.prefix(Int(addressDisplay.count-separator.count)));
	}
}