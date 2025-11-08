import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../main.dart' show isFirebaseInitialized;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth? get _auth => isFirebaseInitialized ? FirebaseAuth.instance : null;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth?.currentUser;

  // Get user ID
  String? get userId => _auth?.currentUser?.uid;

  // Auth state changes stream
  Stream<User?> get authStateChanges =>
      _auth?.authStateChanges() ?? Stream.value(null);

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    if (_auth == null) {
      throw 'Firebase not configured. Please run: flutterfire configure';
    }
    try {
      final userCredential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (_auth == null) {
      throw 'Firebase not configured. Please run: flutterfire configure';
    }
    try {
      final userCredential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  // Sign out
  Future<void> signOut() async {
    if (_auth == null) {
      throw 'Firebase not configured';
    }
    try {
      await Future.wait([
        _auth!.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw 'Failed to sign out';
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    if (_auth == null) {
      throw 'Firebase not configured. Please run: flutterfire configure';
    }

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth!.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Google sign-in failed: ${e.toString()}';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    if (_auth == null) {
      throw 'Firebase not configured. Please run: flutterfire configure';
    }
    try {
      await _auth!.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send reset email';
    }
  }

  // Update display name
  Future<void> updateDisplayName(String displayName) async {
    if (_auth == null) {
      throw 'Firebase not configured';
    }
    try {
      await _auth!.currentUser?.updateDisplayName(displayName);
    } catch (e) {
      throw 'Failed to update display name';
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    if (_auth == null) {
      throw 'Firebase not configured';
    }
    try {
      await _auth!.currentUser?.delete();
    } catch (e) {
      throw 'Failed to delete account';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak';
      case 'email-already-in-use':
        return 'An account already exists for that email';
      case 'user-not-found':
        return 'No user found for that email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'invalid-email':
        return 'The email address is not valid';
      case 'user-disabled':
        return 'This user account has been disabled';
      case 'too-many-requests':
        return 'Too many requests. Please try again later';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support';
      default:
        return e.message ?? 'An authentication error occurred';
    }
  }
}
