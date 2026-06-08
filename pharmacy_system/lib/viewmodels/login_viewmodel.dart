import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pharmacy_system/services/auth_service.dart';
import '../constants/error_message.dart';

class LoginViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;

  // Email and password login
  Future<void> login() async {
    try {
      log("login function called with email: ${emailController.text}");
      isLoading = true;
      errorMessage = null;
      notifyListeners();

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
      log("${ErrorMessage.LOGIN_ERROR}: $e");
      errorMessage = ErrorMessage.LOGIN_ERROR;
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

  // Google Sign-In
  Future<String?> signInWithGoogle() async {
    try {
      isLoading = true;
      notifyListeners();

      final userCredential = await _authService.signInWithGoogle();
      if (userCredential == null) {
        log("Google sign-in cancelled by user");
        isLoading = false;
        notifyListeners();
        return null;
      }
      final uid = userCredential.user?.uid;

      if (uid != null) {
        return await _checkUserStatus(uid);
      }
    } catch (e) {
      log("Google Sign in error. ${ErrorMessage.LOGIN_ERROR}: $e");
      errorMessage = e.toString().replaceAll("Exception: ", "");
      return errorMessage;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

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

      if (role == 'pharmacist') {
        if (approvalStatus == 'pending') {
          return null;
        }

        if (approvalStatus == 'rejected') {
          return null;
        }
      }

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
