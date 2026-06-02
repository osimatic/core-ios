import Foundation

/*
 * Persistent key-value string cache backed by UserDefaults.
 * Each instance is namespaced by its name to avoid key collisions between caches.
 *
 * Usage:
 *   let cache = LocalStringCache("clocking_params_cache")
 *   cache.save(jsonString, forKey: "emp123_APPLICATION")
 *   let cached = cache.load(forKey: "emp123_APPLICATION")
 */
public class LocalStringCache {

	private let name: String;

	/*
	 * Creates a new cache with the given namespace.
	 *
	 * @param name Namespace prefix used to isolate this cache's keys in UserDefaults.
	 */
	public init(_ name: String) {
		self.name = name;
	}

	/*
	 * Persists a string value for the given key.
	 *
	 * @param value The string to store.
	 * @param forKey The key identifying the entry within this cache.
	 */
	public func save(_ value: String, forKey key: String) {
		UserDefaults.standard.set(value, forKey: buildKey(key));
	}

	/*
	 * Retrieves the stored string for the given key.
	 *
	 * @param forKey The key to look up.
	 * @return The stored string, or nil if not found.
	 */
	public func load(forKey key: String) -> String? {
		return UserDefaults.standard.string(forKey: buildKey(key));
	}

	/*
	 * Removes the entry for the given key.
	 *
	 * @param forKey The key to remove.
	 */
	public func remove(forKey key: String) {
		UserDefaults.standard.removeObject(forKey: buildKey(key));
	}

	/*
	 * Removes all entries belonging to this cache namespace.
	 */
	public func clear() {
		let prefix = name + "_";
		UserDefaults.standard.dictionaryRepresentation().keys
			.filter { $0.hasPrefix(prefix) }
			.forEach { UserDefaults.standard.removeObject(forKey: $0) };
	}

	// MARK: - Private

	private func buildKey(_ key: String) -> String {
		return name + "_" + key;
	}

}