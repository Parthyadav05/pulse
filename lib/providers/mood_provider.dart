import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../services/local_storage_service.dart';
import '../services/firestore_service.dart';

class MoodProvider extends ChangeNotifier {
  final LocalStorageService _localStorageService = LocalStorageService();
  final FirestoreService _firestoreService = FirestoreService();

  List<MoodEntry> _moodEntries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MoodEntry> get moodEntries => _moodEntries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load mood entries from local storage
  Future<void> loadMoodEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _moodEntries = _localStorageService.getAllMoodEntries();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load mood entries: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new mood entry
  Future<bool> addMoodEntry({
    required String emoji,
    required int sentiment,
    String? note,
    String? userId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final entry = MoodEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        emoji: emoji,
        note: note,
        date: DateTime.now(),
        sentiment: sentiment,
        userId: userId,
      );

      // Save locally
      await _localStorageService.addMoodEntry(entry);

      // Save to Firestore if user is logged in
      if (userId != null) {
        try {
          await _firestoreService.addMoodEntry(entry);
        } catch (e) {
          // If cloud sync fails, still keep the local entry
          debugPrint('Failed to sync to cloud: $e');
        }
      }

      // Reload entries
      await loadMoodEntries();
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add mood entry: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update mood entry
  Future<bool> updateMoodEntry(MoodEntry entry) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Update locally
      await _localStorageService.updateMoodEntry(entry);

      // Update in Firestore if user is logged in
      if (entry.userId != null) {
        try {
          await _firestoreService.updateMoodEntry(entry);
        } catch (e) {
          debugPrint('Failed to sync update to cloud: $e');
        }
      }

      // Reload entries
      await loadMoodEntries();
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update mood entry: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete mood entry
  Future<bool> deleteMoodEntry(String id, String? userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Delete locally
      await _localStorageService.deleteMoodEntry(id);

      // Delete from Firestore if user is logged in
      if (userId != null) {
        try {
          await _firestoreService.deleteMoodEntry(id);
        } catch (e) {
          debugPrint('Failed to delete from cloud: $e');
        }
      }

      // Reload entries
      await loadMoodEntries();
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete mood entry: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sync cloud entries to local storage
  Future<void> syncFromCloud(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final cloudEntries = await _firestoreService.getMoodEntries(userId);

      // Merge with local entries (cloud takes precedence)
      for (var cloudEntry in cloudEntries) {
        await _localStorageService.updateMoodEntry(cloudEntry);
      }

      // Reload entries
      await loadMoodEntries();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to sync from cloud: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sync local entries to cloud
  Future<void> syncToCloud(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final localEntries = _localStorageService.getAllMoodEntries();
      final entriesToSync = localEntries
          .map((e) => e.copyWith(userId: userId))
          .toList();

      await _firestoreService.syncLocalToFirestore(entriesToSync);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to sync to cloud: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Analytics methods
  int get totalEntries => _localStorageService.getTotalEntries();
  int get positiveEntries => _localStorageService.getPositiveEntries();
  int get negativeEntries => _localStorageService.getNegativeEntries();
  int get neutralEntries => _localStorageService.getNeutralEntries();
  String? get mostCommonMood => _localStorageService.getMostCommonMood();

  // Get entries for a specific date
  List<MoodEntry> getEntriesByDate(DateTime date) {
    return _localStorageService.getMoodEntriesByDate(date);
  }

  // Get entries in a date range
  List<MoodEntry> getEntriesInRange(DateTime start, DateTime end) {
    return _localStorageService.getMoodEntriesInRange(start, end);
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
