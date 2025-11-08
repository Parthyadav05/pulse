# DailyPulse - Personal Wellness Tracker

A comprehensive Flutter mobile application that helps users track their daily emotional state, view past entries, and gain insights into their mood patterns. DailyPulse combines clean UI design, robust state management, and both local and cloud data persistence to create a seamless wellness tracking experience.

## Overview

Mental health and daily emotional awareness are critical aspects of overall well-being. DailyPulse provides a minimal, intuitive interface for users to:

- Log their daily mood with expressive emojis and optional notes
- View a comprehensive history of past mood entries
- Analyze mood patterns with insightful statistics
- Sync data across devices using Firebase Cloud Storage
- Enjoy a personalized experience with light/dark theme support

The app demonstrates modern Flutter development practices including clean architecture, state management with Provider, local persistence with Hive, and cloud integration with Firebase.

## Features

### Core Features
- **Mood Logging Interface**: Select from 8 distinct mood emojis (very happy, happy, relaxed, neutral, confused, sad, angry, anxious) with sentiment classification
- **Detailed Notes**: Add optional text notes to describe your day and feelings
- **Mood History**: Scrollable list view of all past entries with date, time, emoji, and notes
- **Analytics Dashboard**:
  - Total entry count
  - Positive/Negative/Neutral mood distribution with percentages
  - Most common mood identification
  - Personalized insights based on mood patterns
  - **Interactive Charts**:
    - Sentiment distribution pie chart
    - Mood trend line chart (7-day and 30-day views)
    - Emoji frequency bar chart
- **Data Persistence**: Local storage using Hive for offline access
- **Cloud Sync**: Firebase Firestore integration for cross-device synchronization

### Bonus Features
- **Firebase Authentication**:
  - Email/password authentication
  - **Google Sign-In** (one-tap authentication)
  - Secure user management
  - Automatic cloud sync after login
- **Dark Mode Toggle**: Full support for light and dark themes
- **Smooth Animations**: Animated mood selector with scale transitions
- **Responsive Design**: Clean, modern UI that adapts to different screen sizes
- **State Management**: Efficient Provider-based architecture

## Project Structure

```
lib/
├── main.dart                          # App entry point and initialization
├── models/
│   ├── mood_entry.dart               # MoodEntry data model with Hive annotations
│   └── mood_entry.g.dart             # Generated Hive type adapter
├── services/
│   ├── auth_service.dart             # Firebase Authentication service
│   ├── firestore_service.dart        # Firestore database operations
│   └── local_storage_service.dart    # Hive local storage management
├── providers/
│   ├── auth_provider.dart            # Authentication state management
│   ├── mood_provider.dart            # Mood entries state management
│   └── theme_provider.dart           # Theme switching logic
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart         # User login interface
│   │   └── signup_screen.dart        # User registration interface
│   ├── home/
│   │   └── home_screen.dart          # Main app navigation hub
│   ├── mood/
│   │   ├── add_mood_screen.dart      # Mood logging interface
│   │   └── mood_history_screen.dart  # Historical entries list
│   └── analytics/
│       └── analytics_screen.dart     # Mood statistics and insights
├── widgets/
│   ├── mood_emoji_selector.dart      # Interactive emoji selection grid
│   ├── mood_card.dart                # Mood entry display card
│   ├── sentiment_pie_chart.dart      # Pie chart for sentiment distribution
│   ├── mood_trend_chart.dart         # Line chart for mood trends
│   └── emoji_frequency_chart.dart    # Bar chart for emoji frequency
└── utils/
    └── constants.dart                # App-wide constants and configurations
```

## Technology Stack

- **Flutter SDK**: 3.8.1+
- **State Management**: Provider (6.1.1)
- **Local Storage**: Hive (2.2.3) + Hive Flutter (1.1.0)
- **Cloud Backend**:
  - Firebase Core (2.24.2)
  - Firebase Auth (4.16.0)
  - Cloud Firestore (4.14.0)
  - Google Sign-In (6.2.1)
- **UI Enhancement**:
  - Google Fonts (6.1.0)
  - Intl (0.19.0)
  - FL Chart (0.69.0) - Interactive charts and graphs
- **Additional**: Shared Preferences (2.2.2)

## Setup Instructions

### Prerequisites

1. **Flutter SDK**: Install Flutter 3.8.1 or later
   ```bash
   flutter --version
   ```

2. **Firebase CLI**: Install FlutterFire CLI for Firebase configuration
   ```bash
   dart pub global activate flutterfire_cli
   ```

3. **Git**: Clone or download this repository
   ```bash
   git clone <repository-url>
   cd pulse
   ```

### Installation Steps

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Generate Hive Type Adapters** (Already done, but if needed)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Configure Firebase**

   a. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)

   b. Enable Authentication (Email/Password) and Firestore Database

   c. Run FlutterFire configuration:
   ```bash
   flutterfire configure
   ```

   d. This will create `firebase_options.dart` in your lib directory

   e. Update `main.dart` to import Firebase options:
   ```dart
   import 'firebase_options.dart';

   // In main() function:
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

4. **Run the Application**
   ```bash
   # For development
   flutter run

   # For Android release
   flutter build apk --release

   # For iOS release
   flutter build ios --release
   ```

### Firebase Setup Details

#### 1. Authentication Setup
- Go to Firebase Console → Authentication → Sign-in method
- Enable "Email/Password" provider
- Save changes

#### 2. Firestore Database Setup
- Go to Firebase Console → Firestore Database
- Create database in production mode (or test mode for development)
- Set up security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read/write only their own mood entries
    match /mood_entries/{entryId} {
      allow read, write: if request.auth != null &&
                         request.resource.data.userId == request.auth.uid;
    }
  }
}
```

## Running the App

### Without Firebase (Local Only Mode)
The app will work with local storage only. Users can track moods locally without authentication or cloud sync.

### With Firebase (Full Features)
After Firebase configuration, users can:
- Sign up and log in
- Sync mood entries across devices
- Access data from any device

## Key Design Decisions

### UI/UX Design
- **Material Design 3**: Using the latest Material Design principles for modern aesthetics
- **Emoji-First Approach**: Large, animated emoji buttons make mood selection intuitive and engaging
- **Card-Based Layout**: Clean, organized cards separate different UI sections
- **Consistent Spacing**: 16px padding and 12-24px spacing for visual harmony
- **Color-Coded Sentiments**: Green for positive, orange for neutral, red for negative moods

### State Management
- **Provider Pattern**: Chosen for its simplicity and efficiency
- **Separation of Concerns**: Distinct providers for auth, mood data, and theme
- **Reactive Updates**: UI automatically updates when data changes

### Data Architecture
- **Dual Persistence**: Local-first approach with optional cloud sync
- **Offline Capability**: Full functionality without internet connection
- **Data Consistency**: Cloud sync merges data intelligently

### Emotion Logic
Moods are classified into three sentiment categories:
- **Positive (+1)**: Very Happy, Happy, Relaxed
- **Neutral (0)**: Neutral
- **Negative (-1)**: Confused, Sad, Angry, Anxious

This allows for meaningful analytics while keeping the interface simple.

## Screenshots

(Add screenshots here after running the app)

## Testing

Run tests with:
```bash
flutter test
```

## Future Enhancements

- Calendar heatmap view with visual mood indicators
- ~~Weekly/Monthly mood trend graphs~~ ✅ Implemented
- Mood streak tracking (consecutive positive days)
- Export mood data and charts to CSV/PDF/Images
- Push notifications for daily mood reminders
- Mood triggers and patterns analysis
- Integration with wellness APIs
- Advanced chart features (annotations, custom ranges)
- Comparison charts (week-over-week, month-over-month)

## Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

This project is created for educational purposes as part of a Flutter Developer Assessment.

## Contact

For questions or feedback, please open an issue in the repository.

---

**Generated with Claude Code** - A comprehensive Flutter wellness tracking application demonstrating modern mobile development practices.
