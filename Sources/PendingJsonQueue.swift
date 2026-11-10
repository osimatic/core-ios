import Foundation

/*
 * Persistent FIFO queue of JSON objects backed by UserDefaults.
 * Items are enqueued as JSON strings and dequeued in insertion order.
 * Designed for offline operation queues (e.g. pending clockings awaiting network sync).
 *
 * By default uses UserDefaults.standard. Pass a suiteName to use a separate
 * UserDefaults suite that survives a removePersistentDomain call on the main bundle —
 * required for queues that must persist across logout/login cycles.
 *
 * Usage:
 *   let queue = PendingJsonQueue("pending_clockings", suiteName: "com.example.app.offline")
 *   queue.enqueue(["employee_id": "123", "clocking_action": "DEBUT"])
 *   let items = queue.getAll()        // [[String: Any]]
 *   queue.removeFirst()               // after successful sync
 */
public class PendingJsonQueue {

	private let storageKey: String;
	private let defaults: UserDefaults;

	/*
	 * Lock serializing every read-modify-write of a queue, so that an item enqueued while a drain rewrites the queue is not lost.
	 * Shared by all queues: operations are short and never hold the lock while sending an item.
	 */
	private static let lock = NSLock();

	/*
	 * Creates a queue with the given name.
	 *
	 * @param name      Unique name identifying this queue.
	 * @param suiteName Optional UserDefaults suite name. Use a custom suite when the queue
	 *                  must survive a removePersistentDomain call on the main bundle (e.g. on logout).
	 *                  Defaults to UserDefaults.standard when nil.
	 */
	public init(_ name: String, suiteName: String? = nil) {
		self.storageKey = "pending_queue_" + name;
		self.defaults = suiteName.flatMap { UserDefaults(suiteName: $0) } ?? UserDefaults.standard;
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
		PendingJsonQueue.lock.lock();
		defer { PendingJsonQueue.lock.unlock(); }
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
		PendingJsonQueue.lock.lock();
		defer { PendingJsonQueue.lock.unlock(); }
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

	/*
	 * Returns the number of items marked rejected.
	 */
	public func countRejected() -> Int {
		return getAll().filter { $0[PendingJsonQueue.rejectedKey] as? Bool == true }.count;
	}

	/*
	 * Removes the rejected items that were marked more than maxAgeMs milliseconds ago.
	 * A rejected item without rejectedAtKey (marked before this key existed) is kept.
	 * Must not be called while a drain is running (it would shift the items the drain is about to replace): call it just before draining.
	 *
	 * @param maxAgeMs Maximum age of a rejected item, in milliseconds.
	 * @return The number of removed items.
	 */
	@discardableResult
	public func removeRejected(maxAgeMs: Int64) -> Int {
		PendingJsonQueue.lock.lock();
		defer { PendingJsonQueue.lock.unlock(); }
		let limit = Int64(Date().timeIntervalSince1970 * 1000) - maxAgeMs;
		let list = loadRaw();
		let kept = list.filter { raw in
			guard let item = decode(raw),
				  item[PendingJsonQueue.rejectedKey] as? Bool == true,
				  let rejectedAt = (item[PendingJsonQueue.rejectedAtKey] as? NSNumber)?.int64Value else { return true; }
			return rejectedAt >= limit;
		};
		let removed = list.count - kept.count;
		if (removed > 0) {
			saveRaw(kept);
			NSLog("PendingJsonQueue.removeRejected: %d rejected item(s) removed", removed);
		}
		return removed;
	}

	// MARK: - Drain

	/*
	 * Key marking an item rejected by the server. A rejected item stays in the queue but is never sent again.
	 */
	public static let rejectedKey = "rejected";

	/*
	 * Key holding the server refusal reason on a rejected item (absent when the outcome has no reason).
	 */
	public static let rejectionReasonKey = "rejection_reason";

	/*
	 * Key holding the time (milliseconds since epoch) at which an item was marked rejected.
	 */
	public static let rejectedAtKey = "rejected_at";

	/*
	 * Result of sending one item, returned by the sender passed to drain(send:completion:).
	 */
	public enum SendOutcome {
		/* Item sent: removed from the queue. */
		case sent
		/* Item refused by the server: marked with rejectedKey and kept in the queue. */
		case rejected(reason: String?)
		/* Temporary failure: draining stops, this item and the following ones are kept. */
		case retry
	}

	/*
	 * Sends the queued items in FIFO order, one at a time.
	 *
	 * Items already marked rejected are kept without being sent. After a retry outcome,
	 * the following items are kept without being sent. Items enqueued during the drain
	 * are kept at the end of the queue.
	 *
	 * @param send       Sends one item and calls its completion exactly once with the outcome.
	 * @param completion Called once with true if the whole queue was processed, false if a retry is needed.
	 */
	public func drain(send: @escaping ([String: Any], @escaping (SendOutcome) -> Void) -> Void, completion: @escaping (Bool) -> Void) {
		let snapshot = loadRaw();
		drainStep(snapshot, index: 0, updated: [], send: send, completion: completion);
	}

// MARK: - Private

	private func drainStep(_ snapshot: [String], index: Int, updated: [String], send: @escaping ([String: Any], @escaping (SendOutcome) -> Void) -> Void, completion: @escaping (Bool) -> Void) {
		guard index < snapshot.count else {
			replaceHead(processedCount: snapshot.count, updated: updated);
			completion(true);
			return;
		}

		let raw = snapshot[index];
		guard let item = decode(raw) else {
			// Unreadable entry: kept as is, never sent
			drainStep(snapshot, index: index + 1, updated: updated + [raw], send: send, completion: completion);
			return;
		}

		if item[PendingJsonQueue.rejectedKey] as? Bool == true {
			drainStep(snapshot, index: index + 1, updated: updated + [raw], send: send, completion: completion);
			return;
		}

		send(item) { [weak self] outcome in
			guard let self else { return; }
			switch outcome {
			case .sent:
				self.drainStep(snapshot, index: index + 1, updated: updated, send: send, completion: completion);
			case .rejected(let reason):
				var marked = item;
				marked[PendingJsonQueue.rejectedKey] = true;
				marked[PendingJsonQueue.rejectedAtKey] = Int64(Date().timeIntervalSince1970 * 1000);
				if let reason {
					marked[PendingJsonQueue.rejectionReasonKey] = reason;
				}
				let markedRaw = self.encode(marked) ?? raw;
				self.drainStep(snapshot, index: index + 1, updated: updated + [markedRaw], send: send, completion: completion);
			case .retry:
				// Stop here: this item and the following ones are kept unchanged
				self.replaceHead(processedCount: snapshot.count, updated: updated + Array(snapshot[index...]));
				completion(false);
			}
		}
	}

	/*
	 * Replaces the first processedCount entries with updated, keeping the entries enqueued after them.
	 */
	private func replaceHead(processedCount: Int, updated: [String]) {
		PendingJsonQueue.lock.lock();
		defer { PendingJsonQueue.lock.unlock(); }
		let current = loadRaw();
		let head = min(processedCount, current.count);
		saveRaw(updated + Array(current[head...]));
	}

	private func decode(_ raw: String) -> [String: Any]? {
		guard let data = raw.data(using: .utf8) else { return nil; }
		return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any];
	}

	private func encode(_ item: [String: Any]) -> String? {
		guard let data = try? JSONSerialization.data(withJSONObject: item, options: []) else { return nil; }
		return String(data: data, encoding: .utf8);
	}

	private func loadRaw() -> [String] {
		return defaults.stringArray(forKey: storageKey) ?? [];
	}

	private func saveRaw(_ list: [String]) {
		defaults.set(list, forKey: storageKey);
	}

}