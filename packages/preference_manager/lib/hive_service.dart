import 'package:hive_flutter/hive_flutter.dart';

/// Generic wrapper around Hive for structured/collection local storage.
///
/// Use this for data that doesn't fit the key-value shape of
/// [PreferenceManager] — e.g. cached API responses, lists of domain models,
/// nav config snapshots.
///
/// All read/write helpers auto-open the backing box on demand, so callers
/// never need to track box lifecycle manually.
class HiveService {
  HiveService._();

  static final HiveService instance = HiveService._();

  // --------------------------------------------------------------------------
  // Initialisation
  // --------------------------------------------------------------------------

  /// Call once at app startup (before runApp).
  static Future<void> init() async {
    await Hive.initFlutter();
  }

  /// Register a [TypeAdapter] for a custom object type.
  /// Must be called before opening a box that stores that type.
  void registerAdapter<T>(TypeAdapter<T> adapter) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  // --------------------------------------------------------------------------
  // Box lifecycle
  // --------------------------------------------------------------------------

  /// Opens a box by [boxName] and returns it.
  Future<Box<T>> openBox<T>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<T>(boxName);
    }
    return Hive.openBox<T>(boxName);
  }

  /// Opens a lazy box (values are loaded on demand, better for large datasets).
  Future<LazyBox<T>> openLazyBox<T>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.lazyBox<T>(boxName);
    }
    return Hive.openLazyBox<T>(boxName);
  }

  /// Returns an already-open box. Throws if the box is not open.
  Box<T> getBox<T>(String boxName) => Hive.box<T>(boxName);

  /// Flushes and closes a single box.
  Future<void> closeBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
  }

  /// Flushes and closes all open boxes.
  Future<void> closeAllBoxes() => Hive.close();

  /// Deletes the box file from disk (all data is lost).
  Future<void> deleteBox(String boxName) => Hive.deleteBoxFromDisk(boxName);

  // --------------------------------------------------------------------------
  // Write operations
  // --------------------------------------------------------------------------

  /// Stores [value] under [key]. Overwrites any existing value for that key.
  Future<void> put<T>(String boxName, String key, T value) async {
    final box = await openBox<T>(boxName);
    await box.put(key, value);
  }

  /// Appends [value] to the box using an auto-incremented integer key.
  /// Returns the key assigned to the new entry.
  Future<int> add<T>(String boxName, T value) async {
    final box = await openBox<T>(boxName);
    return box.add(value);
  }

  /// Stores multiple key-value pairs at once (single write transaction).
  Future<void> putAll<T>(String boxName, Map<String, T> entries) async {
    final box = await openBox<T>(boxName);
    await box.putAll(entries);
  }

  // --------------------------------------------------------------------------
  // Read operations
  // --------------------------------------------------------------------------

  /// Returns the value stored under [key], or [defaultValue] if absent.
  Future<T?> get<T>(String boxName, String key, {T? defaultValue}) async {
    final box = await openBox<T>(boxName);
    return box.get(key, defaultValue: defaultValue);
  }

  /// Returns all values in the box as a list.
  Future<List<T>> getAll<T>(String boxName) async {
    final box = await openBox<T>(boxName);
    return box.values.toList();
  }

  /// Returns all key-value pairs in the box.
  Future<Map<dynamic, T>> toMap<T>(String boxName) async {
    final box = await openBox<T>(boxName);
    return box.toMap();
  }

  /// Returns all keys stored in the box.
  Future<Iterable<dynamic>> getKeys<T>(String boxName) async {
    final box = await openBox<T>(boxName);
    return box.keys;
  }

  /// Returns `true` if [key] exists in the box.
  Future<bool> containsKey<T>(String boxName, String key) async {
    final box = await openBox<T>(boxName);
    return box.containsKey(key);
  }

  /// Returns the number of entries in the box.
  Future<int> count<T>(String boxName) async {
    final box = await openBox<T>(boxName);
    return box.length;
  }

  /// Returns `true` if the box has no entries.
  Future<bool> isEmpty<T>(String boxName) async {
    final box = await openBox<T>(boxName);
    return box.isEmpty;
  }

  // --------------------------------------------------------------------------
  // Delete operations
  // --------------------------------------------------------------------------

  /// Removes the entry with [key] from the box.
  Future<void> remove<T>(String boxName, String key) async {
    final box = await openBox<T>(boxName);
    await box.delete(key);
  }

  /// Removes all entries whose keys are in [keys].
  Future<void> removeAll<T>(String boxName, List<String> keys) async {
    final box = await openBox<T>(boxName);
    await box.deleteAll(keys);
  }

  /// Removes every entry from the box (box file is kept on disk).
  Future<void> clearBox<T>(String boxName) async {
    final box = await openBox<T>(boxName);
    await box.clear();
  }

  // --------------------------------------------------------------------------
  // Watch (reactive)
  // --------------------------------------------------------------------------

  /// Returns a [Stream] that emits a [BoxEvent] whenever the box changes.
  /// Pass a [key] to listen to changes on a single entry only.
  Future<Stream<BoxEvent>> watch<T>(String boxName, {String? key}) async {
    final box = await openBox<T>(boxName);
    return box.watch(key: key);
  }
}
