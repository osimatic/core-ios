import Foundation

/*
 * Extension on Date providing convenience accessors and formatting helpers.
 */
extension Date {

	/*
	 * Returns true if this date represents the same calendar day as the given date.
	 */
	func isDateEqualsTo(_ date: Date) -> Bool {
		return self.getYear() == date.getYear() && self.getMonth() == date.getMonth() && self.getDayOfMonth() == date.getDayOfMonth();
	}

	/*
	 * Returns the value of a given calendar component for this date.
	 */
	func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
		return calendar.component(component, from: self);
	}

	/* Returns the year component of this date. */
	func getYear() -> Int {
		return self.get(.year);
	}
	/* Returns the month component of this date (1–12). */
	func getMonth() -> Int {
		return self.get(.month);
	}
	/* Returns the day-of-month component of this date (1–31). */
	func getDayOfMonth() -> Int {
		return self.get(.day);
	}

	/* Returns the date formatted as "yyyy-MM-dd" (SQL date). */
	func getSqlDate() -> String {
		let df = DateFormatter();
		df.dateFormat = "yyyy-MM-dd";
		return df.string(from: self);
	}
	/* Returns the time formatted as "HH:mm:ss" (SQL time). */
	func getSqlTime() -> String {
		let df = DateFormatter();
		df.dateFormat = "HH:mm:ss";
		return df.string(from: self);
	}
	/* Returns the date and time formatted as "yyyy-MM-dd HH:mm:ss" (SQL datetime). */
	func getSqlDateTime() -> String {
		return self.getSqlDate()+" "+self.getSqlTime();
	}

	/* Returns the date formatted as "dd/MM/yyyy". */
	func formatDate() -> String {
		let df = DateFormatter();
		df.dateFormat = "dd/MM/yyyy";
		return df.string(from: self);
	}
	/* Returns the time formatted as "HH:mm". */
	func formatTime() -> String {
		let df = DateFormatter();
		df.dateFormat = "HH:mm";
		return df.string(from: self);
	}

	/* Returns a localized date-time display string. */
	func formatDateTime() -> String {
		return String(format: String.localize("dateTimeDisplay"), self.formatDate(), self.formatTime());
	}
}

/*
 * Utility class for date manipulation and parsing.
 */
class DateTime {

	// ------------------------------------------------------------
	// General helpers
	// ------------------------------------------------------------

	/*
	 * Returns the localized weekday name for a given weekday number.
	 *
	 * @param weekdayNumber    The weekday index. When dependingOnLocale is true, 0 is the
	 *                         first day of the week for the current locale. When false, 1
	 *                         maps to Monday, 2 to Tuesday, etc. (ISO week order).
	 * @param dependingOnLocale If true, the index is relative to the locale's first weekday.
	 */
	static func getWeekdayNameFromWeekdayNumber(_ weekdayNumber: Int, dependingOnLocale: Bool = true) -> String {
		let calendar = Calendar.current;

		// Fetch the days of the week in words for the current language (Sunday to Saturday)
		let weekdaySymbols = calendar.weekdaySymbols;

		if (!dependingOnLocale) {
			// 1 -> Monday, 2 -> Tuesday, etc.
			let index = (weekdayNumber) % 7;
			return weekdaySymbols[index];
		}

		// Because the first week day changes depending on the region settings.
		//  ie. In Bangladesh the first day of the week is Friday. In UK it is Monday
		let index = (weekdayNumber - 1 + calendar.firstWeekday - 1) % 7;
		return weekdaySymbols[index];
	}

	// ------------------------------------------------------------
	// Helpers from year / month / day
	// ------------------------------------------------------------

	/*
	 * Returns a Date built from the given year, month and day components.
	 * Falls back to the current date if the components are invalid.
	 */
	static func getDateFrom(year: Int, month: Int, day: Int) -> Date {
		var components = DateComponents();
		components.year = year;
		components.month = month;
		components.day = day;
		return Calendar.current.date(from: components) ?? Date();
	}

	/* Returns a new date by adding the given number of days. */
	static func addDays(_ date: Date, _ nbDays: Int) -> Date {
		return Calendar.current.date(byAdding: .day, value: nbDays, to: date)!;
	}
	/* Returns a new date by adding the given number of months. */
	static func addMonths(_ date: Date, _ nbMonths: Int) -> Date {
		return Calendar.current.date(byAdding: .month, value: nbMonths, to: date)!;
	}
	/* Returns a new date by adding the given number of years. */
	static func addYears(_ date: Date, _ nbYears: Int) -> Date {
		return Calendar.current.date(byAdding: .year, value: nbYears, to: date)!;
	}

	/* Returns the first day of the given month. */
	static func getFirstDayOfMonth(year: Int, month: Int) -> Date {
		return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self.getDateFrom(year: year, month: month, day: 1))))!;
	}
	/* Returns the last day of the given month. */
	static func getLastDayOfMonth(year: Int, month: Int) -> Date {
		return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: getFirstDayOfMonth(year: year, month: month))!;
	}

	// ------------------------------------------------------------
	// Helpers from SQL date / time strings
	// ------------------------------------------------------------

	/*
	 * Parses a SQL datetime string ("yyyy-MM-dd HH:mm:ss", UTC) into a Date.
	 * Returns nil if the string does not match the expected format.
	 */
	static func parseFromSqlDateTime(_ sqlDateTime: String) -> Date? {
		let df = DateFormatter();
		df.timeZone = TimeZone(abbreviation: "UTC");
		df.dateFormat = "yyyy-MM-dd HH:mm:ss";
		return df.date(from: sqlDateTime);
	}
}

/*
 * Utility class for converting Unix timestamps to dates and formatted strings.
 */
class Timestamp {

	/*
	 * Returns a Date from a Unix timestamp (seconds since 1970-01-01).
	 */
	static func getNSDate(_ timestamp: Double) -> Date {
		return Date(timeIntervalSince1970: timestamp);
	}

	/* Returns the SQL date string ("yyyy-MM-dd") for a given timestamp. */
	static func getSqlDate(_ timestamp: Double) -> String {
		return Timestamp.getNSDate(timestamp).getSqlDate();
	}
	/* Returns the SQL time string ("HH:mm:ss") for a given timestamp. */
	static func getSqlTime(_ timestamp: Double) -> String {
		return Timestamp.getNSDate(timestamp).getSqlTime();
	}
	/* Returns the SQL datetime string ("yyyy-MM-dd HH:mm:ss") for a given timestamp. */
	static func getSqlDateTime(_ timestamp: Double) -> String {
		return Timestamp.getNSDate(timestamp).getSqlDateTime();
	}

	/* Returns the display date string ("dd/MM/yyyy") for a given timestamp. */
	static func formatDate(_ timestamp: Double) -> String {
		return Timestamp.getNSDate(timestamp).formatDate();
	}
	/* Returns the display time string ("HH:mm") for a given timestamp. */
	static func formatTime(_ timestamp: Double) -> String {
		return Timestamp.getNSDate(timestamp).formatTime();
	}
	/* Returns the localized date-time display string for a given timestamp. */
	static func formatDateTime(_ timestamp: Double) -> String {
		return Timestamp.getNSDate(timestamp).formatDateTime();
	}
}

/*
 * Utility class for formatting and computing date periods.
 */
class DatePeriod {

	/* Returns a localized display string for a date range. */
	static func format(_ startDate: Date, _ endDate: Date) -> String {
		return String(format: String.localize("periodDisplay"), startDate.formatDate(), endDate.formatDate());
	}

	/*
	 * Returns the number of calendar days between two dates, inclusive of both endpoints.
	 */
	static func getNbDays(_ from: Date, and to: Date) -> Int {
		let c = Calendar.current;
		let fromDate = c.startOfDay(for: from)
		let toDate = c.startOfDay(for: to)
		let numberOfDays = c.dateComponents([.day], from: fromDate, to: toDate)

		return numberOfDays.day! + 1
	}
}