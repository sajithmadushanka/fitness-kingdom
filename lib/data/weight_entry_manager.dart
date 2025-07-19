// data/weight_entry_manager.dart (or wherever your WeightEntryManager is located)

import 'package:fitness_kingdom/models/weight_mode.dart';
import 'package:flutter/foundation.dart'; // For ValueNotifier
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart'; // For Hive.isBoxOpen

class WeightEntryManager {
  static const String _boxName = 'weightEntries';

  Box<WeightEntry>? _weightBox; // Now it's nullable

  // ValueNotifier to notify listeners about changes
  final ValueNotifier<List<WeightEntry>> _weightEntriesNotifier = ValueNotifier(
    [],
  );

  ValueNotifier<List<WeightEntry>> get weightEntriesNotifier =>
      _weightEntriesNotifier;

  // --- START: Singleton Pattern Implementation ---

  // Private constructor
  WeightEntryManager._privateConstructor();

  // Singleton instance
  static final WeightEntryManager _instance =
      WeightEntryManager._privateConstructor();

  // Factory constructor to return the singleton instance
  factory WeightEntryManager() {
    return _instance;
  }

  // --- END: Singleton Pattern Implementation ---

  Future<void> init() async {
    // await Hive.deleteBoxFromDisk(_boxName);
    // Ensure adapter is registered (good to have here, but main() is the primary place)
    if (!Hive.isAdapterRegistered(WeightEntryAdapter().typeId)) {
      Hive.registerAdapter(WeightEntryAdapter());
    }

    // Check if the box is already open to prevent errors if init is called multiple times
    if (!Hive.isBoxOpen(_boxName)) {
      _weightBox = await Hive.openBox<WeightEntry>(_boxName);
      debugPrint(
        "WeightEntryManager: Box opened successfully.",
      ); // For debugging
    } else {
      _weightBox = Hive.box<WeightEntry>(
        _boxName,
      ); // Get reference to already open box
      debugPrint("WeightEntryManager: Box was already open."); // For debugging
    }
    _loadEntries(); // Load initial entries after ensuring box is open
  }

  void _loadEntries() {
    // Only proceed if _weightBox is not null and is open
    if (_weightBox != null && _weightBox!.isOpen) {
      final sortedEntries = _weightBox!.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      _weightEntriesNotifier.value = sortedEntries;
    } else {
      debugPrint(
        "Error: WeightEntryManager: _weightBox is not initialized or not open when trying to load entries.",
      );
      // You might want to handle this more gracefully in a real app,
      // e.g., by showing an error message to the user or retrying init.
    }
  }

  Future<void> addEntry(WeightEntry entry) async {
    debugPrint("WeightEntryManager: Attempting to add entry...");
    // Check if _weightBox is initialized and open before using it
    if (_weightBox != null && _weightBox!.isOpen) {
      await _weightBox!.add(entry); // Use the null-safe operator !
      _loadEntries(); // Reload and notify after adding
      debugPrint("WeightEntryManager: Entry added successfully.");
    } else {
      debugPrint(
        "Error: WeightEntryManager: Weight box not open or not initialized. Cannot add entry.",
      );
      // Consider throwing an exception or providing user feedback here
    }
  }

  Future<void> updateEntry(todaysIndex, updatedEntry) async {
    if (_weightBox != null && _weightBox!.isOpen) {
      await _weightBox!.put(todaysIndex, updatedEntry);
      _loadEntries(); // Reload and notify after adding
      debugPrint("WeightEntryManager: Entry update successfully.");
    } else {
      debugPrint(
        "Error: WeightEntryManager: Weight box not open or not initialized. Cannot add entry.",
      );
      // Consider throwing an exception or providing user feedback here
    }
  }

  Future<void> deleteEntry(int index) async {
    if (_weightBox != null && _weightBox!.isOpen) {
      await _weightBox!.deleteAt(index);
      _loadEntries(); // Reload and notify after deleting
      debugPrint("WeightEntryManager: Entry deleted successfully.");
    } else {
      debugPrint(
        "Error: WeightEntryManager: Weight box not open or not initialized. Cannot delete entry.",
      );
    }
  }

  // No change needed for getAllEntries, as it uses the notifier directly
  List<WeightEntry> getAllEntries() {
    return _weightEntriesNotifier.value;
  }

  // Dispose the Hive box
  void dispose() {
    if (_weightBox != null && _weightBox!.isOpen) {
      _weightBox!.close();
      debugPrint('WeightEntryManager: Box closed.');
    }
  }
}
