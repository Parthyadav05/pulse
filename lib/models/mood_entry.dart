import 'package:hive/hive.dart';

part 'mood_entry.g.dart';

@HiveType(typeId: 0)
class MoodEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String emoji;

  @HiveField(2)
  String? note;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  int sentiment; // 1 = positive, 0 = neutral, -1 = negative

  @HiveField(5)
  String? userId;

  MoodEntry({
    required this.id,
    required this.emoji,
    this.note,
    required this.date,
    required this.sentiment,
    this.userId,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'emoji': emoji,
      'note': note,
      'date': date.toIso8601String(),
      'sentiment': sentiment,
      'userId': userId,
    };
  }

  // Create from Firestore Map
  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] ?? '',
      emoji: map['emoji'] ?? '',
      note: map['note'],
      date: DateTime.parse(map['date']),
      sentiment: map['sentiment'] ?? 0,
      userId: map['userId'],
    );
  }

  // Copy with method
  MoodEntry copyWith({
    String? id,
    String? emoji,
    String? note,
    DateTime? date,
    int? sentiment,
    String? userId,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      note: note ?? this.note,
      date: date ?? this.date,
      sentiment: sentiment ?? this.sentiment,
      userId: userId ?? this.userId,
    );
  }
}
