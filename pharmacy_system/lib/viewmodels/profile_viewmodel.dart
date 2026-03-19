import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String name = "";
  String age = "";
  String gender = "";
  String weight = "";
  String height = "";
  String allergies = "";

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final genderController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final allergiesController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool hasProfile = false;

  void clearControllers() {
    nameController.clear();
    ageController.clear();
    genderController.clear();
    weightController.clear();
    heightController.clear();
    allergiesController.clear();
  }

  Future<void> checkProfileExists() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      hasProfile = false;
      notifyListeners();
      return;
    }

    final doc = await _firestore.collection("profiles").doc(user.uid).get();

    hasProfile = doc.exists;
    notifyListeners();
  }

  Future<bool> saveProfile() async {
    try {
      isLoading = true;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;

      await _firestore.collection("profiles").doc(user!.uid).set({
        "name": nameController.text,
        "age": int.tryParse(ageController.text) ?? 0,
        "gender": genderController.text,
        "weight": weightController.text,
        "height": heightController.text,
        "allergies": allergiesController.text,
      });

      hasProfile = true; // 🔥 IMPORTANT
      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final doc = await _firestore.collection("profiles").doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data()!;

        name = data["name"] ?? "";
        age = data["age"].toString();
        gender = data["gender"] ?? "";
        weight = data["weight"] ?? "";
        height = data["height"] ?? "";
        allergies = data["allergies"] ?? "";

        nameController.text = name;
        ageController.text = age;
        genderController.text = gender;
        weightController.text = weight;
        heightController.text = height;
        allergiesController.text = allergies;

        notifyListeners();
      }
    } catch (e) {
      errorMessage = "Failed to load profile.";
      notifyListeners();
    }
  }

  Future<bool> updateProfile() async {
    try {
      isLoading = true;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;

      await _firestore.collection("profiles").doc(user!.uid).update({
        "name": nameController.text,
        "age": int.tryParse(ageController.text) ?? 0,
        "gender": genderController.text,
        "weight": weightController.text,
        "height": heightController.text,
        "allergies": allergiesController.text,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      // update local variables (important)
      name = nameController.text;
      age = ageController.text;
      gender = genderController.text;
      weight = weightController.text;
      height = heightController.text;
      allergies = allergiesController.text;

      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = "Server timeout / update failed";
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProfile() async {
    try {
      isLoading = true;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;

      await _firestore.collection("profiles").doc(user!.uid).delete();

      clearControllers();

      hasProfile = false; // 🔥 VERY IMPORTANT
      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
