import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Authentication service class.
///
/// This class handles all authentication-related operations
/// using Firebase Authentication, including:
/// - User registration.
/// - Email and password login.
/// - Google authentication.
/// - Password reset.
/// - User logout.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Sign up with email & password
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      log("Attempting to sign up with email: $email");
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
      log("User created successfully with email: $email");
      return userCredential;
    } on FirebaseAuthException catch (e) {
      log("Sign-up failed: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      log("An unknown error occurred: $e");
      rethrow;
    }
  }

  // Sign in with email & password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      log("Attempting to sign in with email: $email");
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      log("Sign-in failed: ${e.message}");
      rethrow;
    } catch (e) {
      log("An unknown error occurred: $e");
      throw Exception('An unknown error occurred');
    }
  }

  /// Authenticates user using Google Sign-In.
  ///
  /// Process:
  /// 1. Opens Google account selection.
  /// 2. Retrieves Google authentication token.
  /// 3. Creates Firebase credential.
  /// 4. Signs in using Firebase Authentication.
  ///
  /// Returns:
  /// - UserCredential if successful.
  /// - Null if user cancels Google login.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      if (gUser == null) {
        return null;
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      log("Google Sign-In failed: $e");
      throw Exception('Google Sign-In failed');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _firebaseAuth.signOut();
  }

  Future<void> logout() async {
    final AuthService auth = AuthService();
    await auth.signOut();
  }

  String? get userId {
    return _firebaseAuth.currentUser?.uid;
  }
}
