import Foundation
import Network

/*
 * Singleton that monitors network connectivity in real time using NWPathMonitor.
 * Call NetworkMonitor.shared.start() once at app launch (e.g. in AppDelegate).
 * Subscribe to onStatusChange to react to connectivity changes in the UI.
 */
public class NetworkMonitor {

	/* Shared singleton instance. */
	public static let shared = NetworkMonitor();

	private let monitor = NWPathMonitor();
	private let monitorQueue = DispatchQueue(label: "com.osimatic.NetworkMonitor");

	/* Current connectivity state. Updated on the main thread. */
	public private(set) var isOnline: Bool = true;

	/*
	 * Called on the main thread whenever connectivity changes.
	 * Parameter is true when the network becomes available, false when it is lost.
	 */
	public var onStatusChange: ((Bool) -> Void)?;

	private init() {}

	/*
	 * Starts monitoring network path changes.
	 * Should be called once at app launch.
	 */
	public func start() {
		monitor.pathUpdateHandler = { [weak self] path in
			let online = path.status == .satisfied;
			DispatchQueue.main.async {
				guard let self = self else { return; }
				let changed = self.isOnline != online;
				self.isOnline = online;
				if (changed) {
					NSLog("NetworkMonitor: status changed -> %@", online ? "online" : "offline");
					self.onStatusChange?(online);
				}
			}
		}
		monitor.start(queue: monitorQueue);
		NSLog("NetworkMonitor: started");
	}

	/*
	 * Stops monitoring network path changes.
	 */
	public func stop() {
		monitor.cancel();
		NSLog("NetworkMonitor: stopped");
	}

}