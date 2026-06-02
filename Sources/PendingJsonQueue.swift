import Foundation

/*
 * Persistent FIFO queue of JSON objects backed by UserDefaults.
 * Items are enqueued as JSON strings and dequeued in insertion order.
 * Designed for offline operation queues (e.g. pending clockings awaiting network sync).
 *
 * Usage:
 *   let queue = PendingJsonQueue("pending_clockings")
 *   queue.enqueue(["employee_id": "123", "clocking_action": "DEBUT"])
 *   let items = queue.getAll()        // [[String: Any]]
 *   queue.removeFirst()               // after successful sync
 */
public class PendingJsonQueue {

	private let storageKey: String;

	/*
	 * Creates a queue with the given name.
	 * The name is used as the UserDefaults storage key.
	 *
	 * @param name Unique name identifying this queue.
	 */
	public init(_ name: String) {
		self.storageKey = "pending_queue_" + name;
	}

	/*
	 * Appends a JSON-serializable dictionary to the end of the queue.
	 *
	 * @param item A dictionary that can be serialized to JSON.
	 */
	public func enqueue(_ item: [String: Any]) {
		guard let data = try? JSONSerialization.data(withJSONObject: item, options: []),
			  let json = String(data: data, encoding: .utf8) else {
			NSLog("PendingJsonQueue.enqueue: failed to serialize item");
			return;
		}
		var list = loadRaw();
		list.append(json);
		saveRaw(list);
		NSLog("PendingJsonQueue.enqueue: queue size is now %d", list.count);
	}

	/*
	 * Returns all queued items in insertion order.
	 * Items that fail to deserialize are silently skipped.
	 *
	 * @return An array of dictionaries in FIFO order.
	 */
	public func getAll() -> [[String: Any]] {
		return loadRaw().compactMap { jsonStr in
			guard let data = jsonStr.data(using: .utf8),
				  let obj = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
				return nil;
			}
			return obj;
		};
	}

	/*
	 * Removes the oldest item from the queue (FIFO).
	 * No-op if the queue is empty.
	 */
	public func removeFirst() {
		var list = loadRaw();
		if (list.isEmpty) { return; }
		list.removeFirst();
		saveRaw(list);
		NSLog("PendingJsonQueue.removeFirst: queue size is now %d", list.count);
	}

	/*
	 * Returns the number of items currently in the queue.
	 */
	public func count() -> Int {
		return loadRaw().count;
	}

	/*
	 * Returns true if the queue contains no items.
	 */
	public func isEmpty() -> Bool {
		return loadRaw().isEmpty;
	}

	/*
	 * Removes all items from the queue.
	 */
	public func clear() {
		saveRaw([]);
	}

	// MARK: - Private

	private func loadRaw() -> [String] {
		return UserDefaults.standard.stringArray(forKey: storageKey) ?? [];
	}

	private func saveRaw(_ list: [String]) {
		UserDefaults.standard.set(list, forKey: storageKey);
	}

}