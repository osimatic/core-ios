import Foundation

/*
 * Utility class for formatting durations expressed in days, hours, or seconds.
 */
class Duration {

	// ------------------------------------------------------------
	// Helpers for durations expressed in days
	// ------------------------------------------------------------

	/* Formats a number of days as a signed or unsigned decimal string. */
	static func formatNbDays(_ nbDays: Int, withSign: Bool = false) -> String {
		return Duration.formatNbDays(Float(nbDays), withSign: withSign);
	}
	static func formatNbDays(_ nbDays: Double, withSign: Bool = false) -> String {
		return Duration.formatNbDays(Float(nbDays), withSign: withSign);
	}
	static func formatNbDays(_ nbDays: Float, withSign: Bool = false) -> String {
		return String(format: "%@ %.02f", (nbDays>=0 ? (withSign ? "+" : "") : "-"), Float(abs(nbDays)));
	}

	// ------------------------------------------------------------
	// Helpers for durations expressed in hours
	// ------------------------------------------------------------

	/*
	 * Formats a duration (given in seconds) as a signed hours:minutes string.
	 *
	 * @param nbSeconds The total duration in seconds.
	 * @param withSign  If true, prepends "+" for positive values.
	 */
	static func formatNbHours(_ nbSeconds: Double, withSign: Bool = false) -> String {
		return Duration.formatNbHours(Int(nbSeconds), withSign: withSign);
	}
	static func formatNbHours(_ nbSeconds: Float, withSign: Bool = false) -> String {
		return Duration.formatNbHours(Int(nbSeconds), withSign: withSign);
	}
	static func formatNbHours(_ nbSeconds: Int, withSign: Bool = false) -> String {
		return String(format: "%@ %@", (nbSeconds>=0 ? (withSign ? "+" : "") : "-"), Duration.formatNbSeconds(nbSeconds));
	}

	// ------------------------------------------------------------
	// Helpers for durations expressed in seconds
	// ------------------------------------------------------------

	/*
	 * Formats a duration in seconds as "HH:mm.ss".
	 */
	static func formatNbSeconds(_ nbSeconds: Double) -> String {
		return Duration.formatNbSeconds(Int(nbSeconds), withSeconds: true, withHours: true);
	}
	static func formatNbSeconds(_ nbSeconds: Float) -> String {
		return Duration.formatNbSeconds(Int(nbSeconds), withSeconds: true, withHours: true);
	}
	static func formatNbSeconds(_ nbSeconds: Int) -> String {
		return Duration.formatNbSeconds(nbSeconds, withSeconds: true, withHours: true);
	}

	static func formatNbSeconds(_ nbSeconds: Double, withHours: Bool) -> String {
		return Duration.formatNbSeconds(Int(nbSeconds), withSeconds: true, withHours: withHours);
	}
	static func formatNbSeconds(_ nbSeconds: Float, withHours: Bool) -> String {
		return Duration.formatNbSeconds(Int(nbSeconds), withSeconds: true, withHours: withHours);
	}
	static func formatNbSeconds(_ nbSeconds: Int, withHours: Bool) -> String {
		return Duration.formatNbSeconds(nbSeconds, withSeconds: true, withHours: withHours);
	}

	static func formatNbSeconds(_ nbSeconds: Double, withSeconds: Bool) -> String {
		return Duration.formatNbSeconds(Int(nbSeconds), withSeconds: withSeconds, withHours: true);
	}
	static func formatNbSeconds(_ nbSeconds: Float, withSeconds: Bool) -> String {
		return Duration.formatNbSeconds(Int(nbSeconds), withSeconds: withSeconds, withHours: true);
	}
	static func formatNbSeconds(_ nbSeconds: Int, withSeconds: Bool) -> String {
		return Duration.formatNbSeconds(nbSeconds, withSeconds: withSeconds, withHours: true);
	}

	/*
	 * Formats a duration in seconds as a time string.
	 *
	 * @param nbSeconds   The total duration in seconds (sign is ignored; use formatNbHours for signed output).
	 * @param withSeconds If true, appends the seconds component.
	 * @param withHours   If true, prepends the hours component.
	 */
	static func formatNbSeconds(_ nbSeconds: Int, withSeconds: Bool, withHours: Bool) -> String {
		let nbSeconds = abs(nbSeconds);
		var str = "";
		if (withHours) {
			str += String(format:"%02d:", Int(nbSeconds/3600));
		}
		str += String(format:"%02d", (Int(nbSeconds)%3600)/60);
		if (withSeconds) {
			str += String(format:".%02d", Int(nbSeconds)%60);
		}
		return str;
	}

}