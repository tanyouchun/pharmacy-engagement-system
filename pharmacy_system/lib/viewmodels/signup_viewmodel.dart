import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  /// Tracks whether the new user is a pharmacist or a regular user.
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
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final uid = credential.user?.uid;

      // Store basic role info in Firestore
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': emailController.text.trim(),
          'role': isPharmacist ? 'pharmacist' : 'user',
          'isBlocked': false,
          'isPermanentBan': false,
          'suspendUntil': null,
          'reportCount': 0,
          'name': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      //   Navigate:
      //   - Pharmacist  → pharmacist profile form
      //   - Regular user → just pop back (AuthWrapper will take them to HomePage)
      if (isPharmacist) {
        Navigator.pushReplacementNamed(context, '/pharmacistProfile');
      } else {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      error = e.message;
      log(error.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? 'Signup failed')));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
