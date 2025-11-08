import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/mood_provider.dart';
import 'providers/theme_provider.dart';
import 'services/local_storage_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

// Global flag to track Firebase initialization status
bool isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with generated configuration
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseInitialized = true;
    debugPrint('✅ Firebase initialized successfully');
    debugPrint('✅ Authentication and Firestore are ready');
  } catch (e) {
    isFirebaseInitialized = false;
    debugPrint('❌ Firebase initialization error: $e');
    debugPrint('⚠️  Running in LOCAL-ONLY mode');
    debugPrint('To enable cloud features:');
    debugPrint('1. Run: flutterfire configure');
    debugPrint('2. Enable Authentication and Firestore in Firebase Console');
    debugPrint('3. Restart the app');
  }

  // Initialize local storage
  final localStorageService = LocalStorageService();
  await localStorageService.init();

  runApp(const DailyPulseApp());
}

class DailyPulseApp extends StatelessWidget {
  const DailyPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..init()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()..loadMoodEntries()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'DailyPulse',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // If Firebase is not initialized, skip authentication
    if (!isFirebaseInitialized) {
      return const LocalOnlyScreen();
    }

    final authProvider = context.watch<AuthProvider>();

    // Show appropriate screen based on auth state
    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}

// Screen shown when Firebase is not configured (local-only mode)
class LocalOnlyScreen extends StatelessWidget {
  const LocalOnlyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DailyPulse - Local Mode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showLocalModeInfo(context),
          ),
        ],
      ),
      body: const HomeScreen(),
    );
  }

  void _showLocalModeInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cloud_off),
            SizedBox(width: 12),
            Text('Local Mode'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are running DailyPulse in LOCAL-ONLY mode.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Available features:'),
              SizedBox(height: 8),
              Text('✓ Track daily moods'),
              Text('✓ View mood history'),
              Text('✓ Analytics and insights'),
              Text('✓ Dark mode'),
              Text('✓ Local data storage'),
              SizedBox(height: 16),
              Text('Unavailable features:'),
              SizedBox(height: 8),
              Text('✗ User authentication'),
              Text('✗ Cloud data sync'),
              Text('✗ Multi-device access'),
              SizedBox(height: 16),
              Text(
                'To enable cloud features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Run: flutterfire configure'),
              Text('2. Enable Auth & Firestore in Firebase Console'),
              Text('3. Restart the app'),
              SizedBox(height: 16),
              Text(
                'See FIREBASE_SETUP.md for detailed instructions.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
