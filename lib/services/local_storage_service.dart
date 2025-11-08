import 'package:hive_flutter/hive_flutter.dart';
import '../models/mood_entry.dart';
import '../utils/constants.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  Box<MoodEntry>? _moodBox;

  // Initialize Hive and open boxes
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MoodEntryAdapter());
    }

    // Open boxes
    _moodBox = await Hive.openBox<MoodEntry>(AppConstants.moodBoxName);
  }

  // Get the mood box
  Box<MoodEntry> get moodBox {
    if (_moodBox == null || !_moodBox!.isOpen) {
      throw Exception('Mood box is not initialized');
    }
    return _moodBox!;
  }

  // Add a new mood entry
  Future<void> addMoodEntry(MoodEntry entry) async {
    await moodBox.put(entry.id, entry);
  }

  // Get all mood entries
  List<MoodEntry> getAllMoodEntries() {
    return moodBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
  }

  // Get mood entry by ID
  MoodEntry? getMoodEntry(String id) {
    return moodBox.get(id);
  }

  // Update a mood entry
  Future<void> updateMoodEntry(MoodEntry entry) async {
    await moodBox.put(entry.id, entry);
  }

  // Delete a mood entry
  Future<void> deleteMoodEntry(String id) async {
    await moodBox.delete(id);
  }

  // Get mood entries for a specific date
  List<MoodEntry> getMoodEntriesByDate(DateTime date) {
    return moodBox.values.where((entry) {
      return entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day;
    }).toList();
  }

  // Get mood entries for a date range
  List<MoodEntry> getMoodEntriesInRange(DateTime start, DateTime end) {
    return moodBox.values.where((entry) {
      return entry.date.isAfter(start.subtract(const Duration(days: 1))) &&
          entry.date.isBefore(end.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get total entry count
  int getTotalEntries() {
    return moodBox.length;
  }

  // Get positive entries count
  int getPositiveEntries() {
    return moodBox.values.where((entry) => entry.sentiment > 0).length;
  }

  // Get negative entries count
  int getNegativeEntries() {
    return moodBox.values.where((entry) => entry.sentiment < 0).length;
  }

  // Get neutral entries count
  int getNeutralEntries() {
    return moodBox.values.where((entry) => entry.sentiment == 0).length;
  }

  // Get most common mood emoji
  String? getMostCommonMood() {
    if (moodBox.isEmpty) return null;

    final moodCounts = <String, int>{};
    for (var entry in moodBox.values) {
      moodCounts[entry.emoji] = (moodCounts[entry.emoji] ?? 0) + 1;
    }

    return moodCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Clear all mood entries (for testing/reset)
  Future<void> clearAllEntries() async {
    await moodBox.clear();
  }

  // Close boxes
  Future<void> close() async {
    await _moodBox?.close();
  }
}
