import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mood_entry.dart';
import '../main.dart' show isFirebaseInitialized;

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  FirebaseFirestore? get _firestore =>
      isFirebaseInitialized ? FirebaseFirestore.instance : null;

  // Collection reference
  CollectionReference? get _moodEntriesCollection =>
      _firestore?.collection('mood_entries');

  // Add mood entry to Firestore
  Future<void> addMoodEntry(MoodEntry entry) async {
    if (_moodEntriesCollection == null) {
      return; // Silently skip if Firebase not configured
    }
    try {
      await _moodEntriesCollection!.doc(entry.id).set(entry.toMap());
    } catch (e) {
      throw 'Failed to save mood entry to cloud: $e';
    }
  }

  // Update mood entry in Firestore
  Future<void> updateMoodEntry(MoodEntry entry) async {
    if (_moodEntriesCollection == null) {
      return; // Silently skip if Firebase not configured
    }
    try {
      await _moodEntriesCollection!.doc(entry.id).update(entry.toMap());
    } catch (e) {
      throw 'Failed to update mood entry in cloud: $e';
    }
  }

  // Delete mood entry from Firestore
  Future<void> deleteMoodEntry(String id) async {
    if (_moodEntriesCollection == null) {
      return; // Silently skip if Firebase not configured
    }
    try {
      await _moodEntriesCollection!.doc(id).delete();
    } catch (e) {
      throw 'Failed to delete mood entry from cloud: $e';
    }
  }

  // Get all mood entries for a user
  Future<List<MoodEntry>> getMoodEntries(String userId) async {
    if (_moodEntriesCollection == null) {
      return [];
    }
    try {
      final querySnapshot = await _moodEntriesCollection!
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MoodEntry.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Failed to fetch mood entries from cloud: $e';
    }
  }

  // Stream of mood entries for real-time updates
  Stream<List<MoodEntry>> getMoodEntriesStream(String userId) {
    if (_moodEntriesCollection == null) {
      return Stream.value([]);
    }
    return _moodEntriesCollection!
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MoodEntry.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Sync local entries to Firestore
  Future<void> syncLocalToFirestore(List<MoodEntry> entries) async {
    if (_firestore == null || _moodEntriesCollection == null) {
      throw 'Firebase not configured. Cannot sync to cloud.';
    }
    try {
      final batch = _firestore!.batch();

      for (var entry in entries) {
        final docRef = _moodEntriesCollection!.doc(entry.id);
        batch.set(docRef, entry.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw 'Failed to sync entries to cloud: $e';
    }
  }

  // Get mood entries for a specific date range
  Future<List<MoodEntry>> getMoodEntriesInRange({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    if (_moodEntriesCollection == null) {
      return [];
    }
    try {
      final querySnapshot = await _moodEntriesCollection!
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
          .where('date', isLessThanOrEqualTo: end.toIso8601String())
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MoodEntry.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Failed to fetch mood entries for date range: $e';
    }
  }

  // Delete all mood entries for a user (for account deletion)
  Future<void> deleteAllUserEntries(String userId) async {
    if (_firestore == null || _moodEntriesCollection == null) {
      return;
    }
    try {
      final querySnapshot = await _moodEntriesCollection!
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore!.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw 'Failed to delete user entries: $e';
    }
  }
}
