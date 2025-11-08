# Firebase Configuration Guide for DailyPulse

This guide provides step-by-step instructions for setting up Firebase for the DailyPulse application.

## Prerequisites

- Flutter SDK installed
- Firebase account (free tier is sufficient)
- FlutterFire CLI installed

## Step 1: Install FlutterFire CLI

Open your terminal and run:

```bash
dart pub global activate flutterfire_cli
```

Verify installation:

```bash
flutterfire --version
```

## Step 2: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `dailypulse` (or any name you prefer)
4. Click "Continue"
5. Disable Google Analytics (optional, you can enable it if needed)
6. Click "Create Project"
7. Wait for the project to be created

## Step 3: Configure Firebase for Flutter

In your terminal, navigate to the project directory:

```bash
cd pulse
```

Run the FlutterFire configuration command:

```bash
flutterfire configure
```

This will:
- Show you a list of Firebase projects
- Select your project (dailypulse)
- Ask which platforms to support (select Android, iOS, Web, etc.)
- Generate `firebase_options.dart` in the `lib` folder
- Register your apps with Firebase

## Step 4: Enable Firebase Authentication

1. In Firebase Console, select your project
2. Go to **Build** → **Authentication**
3. Click **Get Started**
4. Go to **Sign-in method** tab
5. Click on **Email/Password**
6. Enable both toggles:
   - Email/Password
   - Email link (passwordless sign-in) - Optional
7. Click **Save**

## Step 5: Set Up Cloud Firestore

1. In Firebase Console, go to **Build** → **Firestore Database**
2. Click **Create Database**
3. Choose a location (select closest to your users)
4. Start in **production mode** (we'll add rules next)
5. Click **Enable**

## Step 6: Configure Firestore Security Rules

1. In Firestore Database, go to **Rules** tab
2. Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read and write only their own mood entries
    match /mood_entries/{entryId} {
      allow read, write: if request.auth != null &&
                         request.resource.data.userId == request.auth.uid;
    }

    // Optional: Allow users to read their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

3. Click **Publish**

## Step 7: Update main.dart

After running `flutterfire configure`, you'll have a `firebase_options.dart` file. Update your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // Import the generated file
import 'providers/auth_provider.dart';
import 'providers/mood_provider.dart';
import 'providers/theme_provider.dart';
import 'services/local_storage_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize local storage
  final localStorageService = LocalStorageService();
  await localStorageService.init();

  runApp(const DailyPulseApp());
}
```

## Step 8: Test Firebase Connection

Run the app:

```bash
flutter run
```

You should see:
- Login/Signup screens
- No Firebase initialization errors in the console
- Ability to sign up with email/password

## Troubleshooting

### Error: "No Firebase App '[DEFAULT]' has been created"
- Make sure you've run `flutterfire configure`
- Verify `firebase_options.dart` exists in your `lib` folder
- Check that you're importing and using `DefaultFirebaseOptions.currentPlatform`

### Error: "PERMISSION_DENIED"
- Check your Firestore security rules
- Ensure the user is authenticated before accessing Firestore
- Verify the userId field matches the authenticated user's UID

### iOS Build Issues
- Run `cd ios && pod install`
- Ensure iOS deployment target is 11.0 or higher in `ios/Podfile`
- Clean and rebuild: `flutter clean && flutter pub get`

### Android Build Issues
- Ensure `minSdkVersion` is at least 21 in `android/app/build.gradle`
- Check that Google Services plugin is properly configured
- Run `flutter clean && flutter pub get`

## Firestore Data Structure

The app uses the following Firestore structure:

```
mood_entries (collection)
  └── {entryId} (document)
      ├── id: string
      ├── emoji: string
      ├── note: string (optional)
      ├── date: string (ISO 8601)
      ├── sentiment: number (-1, 0, or 1)
      └── userId: string
```

## Optional: Enable Firestore Indexes

For better query performance, you may need to create composite indexes:

1. Try using the app's sync feature
2. If you get an error with an index creation link, click it
3. Firebase will automatically create the required index
4. Wait a few minutes for the index to build
5. Try syncing again

## Testing Authentication

1. Run the app
2. Click "Sign Up"
3. Enter email and password
4. Check Firebase Console → Authentication → Users
5. You should see your newly created user

## Testing Firestore

1. Log a mood entry in the app
2. Click "Sync with Cloud"
3. Go to Firebase Console → Firestore Database
4. You should see your mood entry in the `mood_entries` collection

## Next Steps

- Add more Firestore security rules as needed
- Enable Firebase Analytics (optional)
- Set up Firebase Performance Monitoring (optional)
- Configure Firebase Crashlytics (optional)

## Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Authentication](https://firebase.google.com/docs/auth)

---

For additional help, consult the [Firebase Documentation](https://firebase.google.com/docs) or open an issue in the repository.
