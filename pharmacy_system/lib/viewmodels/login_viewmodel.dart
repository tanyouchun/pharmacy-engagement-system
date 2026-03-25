import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  // Email login
  Future<void> login() async {
    try {
      isLoading = true;
      notifyListeners();

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final uid = credential.user?.uid;

      if (uid != null) {
        await _checkUserStatus(uid);
      }
    } on FirebaseAuthException catch (e) {
      log("Login error: $e");
      errorMessage = "Incorrect email or password";
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
      log(errorMessage!);
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

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User cancelled
        isLoading = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final uid = userCredential.user?.uid;

      if (uid != null) {
        await _checkUserStatus(uid);
      }
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
      log(errorMessage!);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkUserStatus(String uid) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    final data = userDoc.data();
    log("User data for $uid: $data");
    if (data?['isBlocked'] == true) {
      final suspendUntil = data?['suspendUntil'];

      if (data?['isPermanentBan'] == true) {
        await FirebaseAuth.instance.signOut(); 
        throw Exception("Account permanently banned");
      }

      if (suspendUntil != null) {
        final until = (suspendUntil as Timestamp).toDate();

        if (DateTime.now().isBefore(until)) {
          await FirebaseAuth.instance.signOut(); 
          throw Exception("Your account is suspended until ${until.toLocal()}");
        } else {
          await userDoc.reference.update({
            'isBlocked': false,
            'suspendUntil': null,
          });
        }
      }
    }
  }
}
