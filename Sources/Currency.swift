import Foundation

/*
 * Utility class for formatting monetary amounts.
 */
class Currency {

	/*
	 * Formats a numeric amount as a localized currency string.
	 * @param amount     The monetary value to format.
	 * @param currency   The ISO 4217 currency code (default: "EUR").
	 * @param nbDecimals The maximum number of decimal places (default: 2).
	 * @return A localized currency string, or an empty string if formatting fails.
	 */
	static func format(_ amount: Double, currency: String = "EUR", nbDecimals: Int = 2) -> String {
		let formatter = NumberFormatter();
		formatter.numberStyle = .currency;
		formatter.currencyCode = currency;
		formatter.maximumFractionDigits = nbDecimals;

		let number = NSNumber(value: amount);
		return formatter.string(from: number) ?? "";
	}
}