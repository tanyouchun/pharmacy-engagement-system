import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../constants/error_message.dart';

class SignupViewModel extends ChangeNotifier {
  final _authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Tracks whether the new user is a pharmacist or a regular user.
  bool isPharmacist = false;
  bool isLoading = false;
  String? error;

  Future<void> signup(BuildContext context) async {
    try {
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      if (password != confirmPassword) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
        return;
      }

      isLoading = true;
      notifyListeners();

      // Create auth user
      final credential = await _authService.signUpWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      final uid = credential.user?.uid;

      // Store basic role info in Firestore
      if (uid != null) {
        final newUser = UserAccount.newUser(
          id: uid,
          email: emailController.text.trim(),
          name: '',
          isPharmacist: isPharmacist,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(newUser.toFirestoreMap());
      }

      // Pharmacist  → pharmacist profile form
      // Regular user → just pop back (AuthWrapper will take them to HomePage)
      if (isPharmacist) {
        Navigator.pushReplacementNamed(context, '/pharmacistProfile');
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      error = e.toString().replaceAll("Exception: ", "");
      log("${ErrorMessage.SIGNUP_ERROR}: $error");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? 'Signup failed')));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
