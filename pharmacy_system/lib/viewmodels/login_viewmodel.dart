import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pharmacy_system/services/auth_service.dart';
import '../constants/error_message.dart';

/// for user authentication.
/// It handles email/password login, Google Sign-In,
/// and verifies user account status before allowing access.
class LoginViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;

  /// Authenticates the user using email and password.
  ///
  /// Workflow:
  /// 1. Authenticate with Firebase Authentication.
  /// 2. Verify account status from Firestore.
  /// 3. Return appropriate error message if access is restricted.
  Future<void> login() async {
    try {
      log("login function called with email: ${emailController.text}");
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Authenticate using Firebase Authentication.
      final credential = await _authService.signInWithEmail(
        emailController.text,
        passwordController.text,
      );
      final uid = credential.user?.uid;
      log("Current logged in user ID: ${credential.user?.uid}");
      if (uid != null) {
        final error = await _checkUserStatus(uid);
        if (error != null) {
          errorMessage = error;
          notifyListeners();
          return;
        }
      }
      log("Login success UID: $uid");
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          errorMessage = "Please enter a valid email address.";
          break;

        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage = "Invalid email or password.";
          break;

        case 'user-disabled':
          errorMessage = "This account has been disabled.";
          break;

        case 'too-many-requests':
          errorMessage = "Too many login attempts. Please try again later.";
          break;

        default:
          errorMessage = e.message ?? "Login failed.";
      }

      notifyListeners();
    } catch (e) {
      log("Email and password SignIn error. ${ErrorMessage.LOGIN_ERROR}: $e");
      errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Authenticates the user using Google Sign-In.
  ///
  /// Existing users proceed to account verification,
  /// while new users are identified for profile creation.
  Future<String?> signInWithGoogle() async {
    try {
      isLoading = true;
      notifyListeners();

      // Launch Google Sign-In authentication flow.
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential == null) {
        log("Google sign-in cancelled by user");
        isLoading = false;
        notifyListeners();
        return null;
      }
      final uid = userCredential.user?.uid;

      if (uid != null) {
        final statusError = await _checkUserStatus(uid);
        if (statusError != null) {
          errorMessage = statusError;
          return statusError;
        }

        return null;
      }

      errorMessage = "Unable to verify account status";
      return errorMessage;
    } catch (e) {
      log("Google Sign in error. ${ErrorMessage.LOGIN_ERROR}: $e");
      errorMessage = e.toString().replaceAll("Exception: ", "");
      return errorMessage;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Verifies the user's account status stored in Firestore.
  ///
  /// This method checks:
  /// - Whether the user profile exists.
  /// - Pharmacist approval status.
  /// - Temporary suspension.
  /// - Permanent account ban.
  Future<String?> _checkUserStatus(String uid) async {
    try {
      log("Checking user status for $uid");

      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        return "NEW_GOOGLE_USER";
      }

      final data = userDoc.data();

      log("User data for $uid: $data");

      final role = data?['role'];
      final approvalStatus = data?['approvalStatus'];

      // Validate pharmacist approval before granting access.
      if (role == 'pharmacist') {
        if (approvalStatus == 'pending' || approvalStatus == null) {
          return "PENDING_PHARMACIST_APPROVAL";
        }

        if (approvalStatus == 'rejected') {
          return "REJECTED_PHARMACIST_APPROVAL";
        }
      }

      // Check whether the account has been blocked.
      if (data?['isBlocked'] == true) {
        final suspendUntil = data?['suspendUntil'];

        if (data?['isPermanentBan'] == true) {
          log("Account $uid permanently banned");

          await FirebaseAuth.instance.signOut();

          return "Account permanently banned";
        }

        // Temporary Suspension
        if (suspendUntil != null) {
          final until = (suspendUntil as Timestamp).toDate();

          if (DateTime.now().isBefore(until)) {
            log("Account $uid suspended until $until");

            await FirebaseAuth.instance.signOut();

            return "Your account is suspended until ${until.toLocal()}";
          } else {
            // auto unblock expired suspension
            await userDoc.reference.update({
              'isBlocked': false,
              'suspendUntil': null,
            });
          }
        }
      }

      return null;
    } catch (e) {
      log("Error checking user status for $uid: $e");

      return "Unable to verify account status";
    }
  }
}
