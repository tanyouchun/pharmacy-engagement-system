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
  Future<void> signInWithGoogle() async {
    try {
      isLoading = true;
      notifyListeners();

      final userCredential = await _authService.signInWithGoogle();
      if (userCredential == null) {
        log("Google sign-in cancelled by user");
        isLoading = false;
        notifyListeners();
        return;
      }
      final uid = userCredential.user?.uid;

      if (uid != null) {
        await _checkUserStatus(uid);
      }
    } catch (e) {
      log("Google Sign in error. ${ErrorMessage.LOGIN_ERROR}: $e");
      errorMessage = e.toString().replaceAll("Exception: ", "");
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
        log("New Google user detected. Creating Firestore record...");

        await userRef.set({
          "email": FirebaseAuth.instance.currentUser?.email ?? "",
          "name": FirebaseAuth.instance.currentUser?.displayName ?? "",
          "role": "user",
          "createdAt": FieldValue.serverTimestamp(),
          "isBlocked": false,
          "suspendUntil": null,
          "reportCount": 0,
          "isPermanentBan": false,
        });

        return null; // New user, no need to check block status
      }

      final data = userDoc.data();
      log("User data for $uid: $data");
      if (data?['isBlocked'] == true) {
        final suspendUntil = data?['suspendUntil'];

        if (data?['isPermanentBan'] == true) {
          log("Account $uid is permanently banned. Signing out user.");
          await FirebaseAuth.instance.signOut();
          return "Account permanently banned";
        }

        if (suspendUntil != null) {
          final until = (suspendUntil as Timestamp).toDate();

          if (DateTime.now().isBefore(until)) {
            log(
              "Account $uid is currently suspended until $until. Signing out user.",
            );
            await FirebaseAuth.instance.signOut();
            return "Your account is suspended until ${until.toLocal()}";
          } else {
            await userDoc.reference.update({
              'isBlocked': false,
              'suspendUntil': null,
            });
          }
        }
      }
    } catch (e) {
      log("Error checking user status for $uid: $e");
      return "Unable to verify account status";
    }
  }
}
