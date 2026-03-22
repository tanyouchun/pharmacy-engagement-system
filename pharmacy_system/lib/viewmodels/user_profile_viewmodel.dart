import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy_system/models/prescription.dart';

class UserProfileViewModel extends ChangeNotifier {
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
  List<Prescription> prescriptions = [];
  bool isLoadingPrescription = false;

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

    final doc =
        await _firestore.collection("user_profiles").doc(user.uid).get();

    hasProfile = doc.exists;
    notifyListeners();
  }

  Future<bool> saveProfile() async {
    try {
      isLoading = true;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;

      await _firestore.collection("user_profiles").doc(user!.uid).set({
        "name": nameController.text,
        "age": int.tryParse(ageController.text) ?? 0,
        "gender": genderController.text,
        "weight": weightController.text,
        "height": heightController.text,
        "allergies": allergiesController.text,
      });

      hasProfile = true;
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

      final doc =
          await _firestore.collection("user_profiles").doc(user.uid).get();

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

  Future<void> loadUserProfile(String userId) async {
    try {
      final doc =
          await _firestore.collection("user_profiles").doc(userId).get();

      if (doc.exists) {
        final data = doc.data()!;

        name = data["name"] ?? "";
        age = data["age"].toString();
        gender = data["gender"] ?? "";
        weight = data["weight"] ?? "";
        height = data["height"] ?? "";
        allergies = data["allergies"] ?? "";

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

      await _firestore.collection("user_profiles").doc(user!.uid).update({
        "name": nameController.text,
        "age": int.tryParse(ageController.text) ?? 0,
        "gender": genderController.text,
        "weight": weightController.text,
        "height": heightController.text,
        "allergies": allergiesController.text,
        "updatedAt": FieldValue.serverTimestamp(),
      });

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

      await _firestore.collection("user_profiles").doc(user!.uid).delete();

      clearControllers();

      hasProfile = false;
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

  //load prescriptions for current user: user_profiles/{userId}/prescriptions
  Future<void> loadUserPrescriptions(String userId) async {
    try {
      isLoadingPrescription = true;
      notifyListeners();

      final snapshot =
          await _firestore
              .collection("user_profiles")
              .doc(userId)
              .collection("prescriptions")
              .get();

      log("Docs count: ${snapshot.docs.length}");

      prescriptions =
          snapshot.docs
              .map((doc) => Prescription.fromMap(doc.id, doc.data()))
              .toList();

      isLoadingPrescription = false;
      notifyListeners();
    } catch (e) {
      log("ERROR: $e");
      errorMessage = "Failed to load prescriptions";
      isLoadingPrescription = false;
      notifyListeners();
    }
  }

  //add: user_profiles/{userId}/prescriptions/{prescriptionId}
  Future<void> addPrescription(String userId, String name, String notes) async {
    await _firestore
        .collection("user_profiles")
        .doc(userId)
        .collection("prescriptions")
        .add({"name": name, "notes": notes, "date": DateTime.now().toString()});

    await loadUserPrescriptions(userId);
  }

  //update: user_profiles/{userId}/prescriptions/{prescriptionId}
  Future<void> updatePrescription(
    String userId,
    String id,
    String name,
    String notes,
  ) async {
    await _firestore
        .collection("user_profiles")
        .doc(userId)
        .collection("prescriptions")
        .doc(id)
        .update({"name": name, "notes": notes});

    await loadUserPrescriptions(userId);
  }

  //delete: user_profiles/{userId}/prescriptions/{prescriptionId}
  Future<void> deletePrescription(String userId, String id) async {
    await _firestore
        .collection("user_profiles")
        .doc(userId)
        .collection("prescriptions")
        .doc(id)
        .delete();

    await loadUserPrescriptions(userId);
  }
}
