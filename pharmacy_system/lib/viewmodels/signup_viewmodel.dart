import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final Map<String, String?> errors = {};

  String passwordStrength = "";
  Color passwordStrengthColor = Colors.grey;

  void checkPasswordStrength(String password) {
    if (password.isEmpty) {
      passwordStrength = "";
      passwordStrengthColor = Colors.grey;
    } else {
      int score = 0;

      if (password.length >= 8) score++;
      if (RegExp(r'[A-Z]').hasMatch(password)) score++;
      if (RegExp(r'[a-z]').hasMatch(password)) score++;
      if (RegExp(r'[0-9]').hasMatch(password)) score++;
      if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

      if (score <= 2) {
        passwordStrength = "Weak";
        passwordStrengthColor = Colors.red;
      } else if (score <= 4) {
        passwordStrength = "Medium";
        passwordStrengthColor = Colors.orange;
      } else {
        passwordStrength = "Strong";
        passwordStrengthColor = Colors.green;
      }
    }

    notifyListeners();
  }

  Future<void> signup(BuildContext context) async {
    try {
      errors.clear();

      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      if (email.isEmpty) {
        errors['email'] = "Email is required";
      }

      if (password.isEmpty) {
        errors['password'] = "Password is required";
      } else if (passwordStrength == "Weak") {
        errors['password'] = ErrorMessage.PASSWORD_NOT_STRONG_ERROR;
      }

      if (confirmPassword.isEmpty) {
        errors['confirmPassword'] = "Please confirm your password";
      } else if (password != confirmPassword) {
        errors['confirmPassword'] = ErrorMessage.PASSWORDS_DO_NOT_MATCH_ERROR;
      }

      if (errors.isNotEmpty) {
        notifyListeners();
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
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          errors['email'] = ErrorMessage.EMAIL_ALREADY_IN_USE_ERROR;
          break;

        case 'invalid-email':
          errors['email'] = ErrorMessage.INVALID_EMAIL_ERROR;
          break;

        case 'weak-password':
          errors['password'] = ErrorMessage.PASSWORD_NOT_STRONG_ERROR;
          break;

        default:
          errors['general'] = e.message ?? "Signup failed.";
      }

      notifyListeners();
    } catch (e) {
      log("Unexpected error: $e");
      errors['general'] = "Something went wrong. Please try again.";
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
