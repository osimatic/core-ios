import Foundation
import SystemConfiguration

/*
 * Helper class for checking network connectivity using the SystemConfiguration framework.
 * Works for both Wi-Fi and cellular connections.
 */
class Reachability {

	/*
	 * Returns true if the device currently has a usable network connection
	 * (Wi-Fi or cellular). Returns false if the reachability object could not
	 * be created or if no connection is available.
	 */
	func isConnectedToNetwork() -> Bool {
		var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
		zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
		zeroAddress.sin_family = sa_family_t(AF_INET)

		let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
			$0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
				SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
			}
		}

		guard let reachability = defaultRouteReachability else {
			return false
		}

		var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
		if SCNetworkReachabilityGetFlags(reachability, &flags) == false {
			return false
		}

		// Works for both cellular and Wi-Fi
		let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
		let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
		return (isReachable && !needsConnection)
	}
}