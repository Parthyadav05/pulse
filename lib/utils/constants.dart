import 'package:flutter/material.dart';

class AppConstants {
  // Mood emojis with sentiment values
  static const Map<String, int> moodEmojis = {
    '😄': 1, // Very Happy - Positive
    '😊': 1, // Happy - Positive
    '😌': 1, // Relaxed - Positive
    '😐': 0, // Neutral - Neutral
    '😕': -1, // Confused - Negative
    '😢': -1, // Sad - Negative
    '😠': -1, // Angry - Negative
    '😰': -1, // Anxious - Negative
  };

  // Get sentiment for emoji
  static int getSentiment(String emoji) {
    return moodEmojis[emoji] ?? 0;
  }

  // Colors
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFFA726);

  // Sentiment colors
  static const Color positiveColor = Color(0xFF4CAF50);
  static const Color neutralColor = Color(0xFFFF9800);
  static const Color negativeColor = Color(0xFFF44336);

  // Box names for Hive
  static const String moodBoxName = 'mood_entries';
  static const String settingsBoxName = 'settings';

  // SharedPreferences keys
  static const String themeKey = 'theme_mode';
  static const String userIdKey = 'user_id';
}

// Mood emoji data class for better structure
class MoodEmojiData {
  final String emoji;
  final String label;
  final int sentiment;

  const MoodEmojiData({
    required this.emoji,
    required this.label,
    required this.sentiment,
  });
}

// Predefined mood emoji list with labels
const List<MoodEmojiData> moodEmojiList = [
  MoodEmojiData(emoji: '😄', label: 'Very Happy', sentiment: 1),
  MoodEmojiData(emoji: '😊', label: 'Happy', sentiment: 1),
  MoodEmojiData(emoji: '😌', label: 'Relaxed', sentiment: 1),
  MoodEmojiData(emoji: '😐', label: 'Neutral', sentiment: 0),
  MoodEmojiData(emoji: '😕', label: 'Confused', sentiment: -1),
  MoodEmojiData(emoji: '😢', label: 'Sad', sentiment: -1),
  MoodEmojiData(emoji: '😠', label: 'Angry', sentiment: -1),
  MoodEmojiData(emoji: '😰', label: 'Anxious', sentiment: -1),
];
