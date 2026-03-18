import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? error;

  Future<void> signup() async {
    try {
      isLoading = true;
      notifyListeners();

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

    } on FirebaseAuthException catch (e) {
      error = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
