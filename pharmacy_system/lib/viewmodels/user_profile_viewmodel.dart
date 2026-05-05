import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy_system/models/prescription.dart';
// import 'package:pharmacy_system/viewmodels/chat_viewmodel.dart';

import '../models/user_profile.dart';
import '../constants/error_message.dart';

class UserProfileViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String name = "";
  String age = "";
  String gender = "";
  String weight = "";
  String height = "";
  String allergies = "";
  String medicalConditions = "";

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final genderController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final allergiesController = TextEditingController();
  final medicalConditionsController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool hasProfile = false;
  List<Prescription> prescriptions = [];
  bool isLoadingPrescription = false;
  User? get _currentUser => FirebaseAuth.instance.currentUser;
  String? get _uid => _currentUser?.uid;

  void clearControllers() {
    nameController.clear();
    ageController.clear();
    genderController.clear();
    weightController.clear();
    heightController.clear();
    allergiesController.clear();
    medicalConditionsController.clear();
  }

  //TODO unuse logout method?
  // Future<void> logout(ChatViewModel chatViewModel) async {
  //   log("Logging out user: ${_uid}");
  //   chatViewModel.disposeListener();
  //   await FirebaseAuth.instance.signOut();
  //   clearControllers();

  //   name = "";
  //   age = "";
  //   gender = "";
  //   weight = "";
  //   height = "";
  //   allergies = "";
  //   medicalConditions = "";

  //   hasProfile = false;

  //   notifyListeners();
  // }

  Future<void> checkProfileExists() async {
    log("Checking user profile existence for UID: ${_uid}");
    _requireAuth();

    final doc = await _firestore.collection("user_profiles").doc(_uid).get();

    hasProfile = doc.exists;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    try {
      log("Loading user profile for UID: ${_uid}");
      _requireAuth();

      final doc = await _firestore.collection("user_profiles").doc(_uid).get();
      log("Loading profile for UID: ${_uid}");

      if (doc.exists) {
        log("user profile exist for user ID: ${_uid}");
        final profile = UserProfile.fromDoc(doc);

        name = profile.name;
        age = profile.age.toString();
        gender = profile.gender;
        weight = profile.weight;
        height = profile.height;
        allergies = profile.allergies.join(', ');
        medicalConditions = profile.medicalConditions.join(', ');

        nameController.text = name;
        ageController.text = age;
        genderController.text = gender;
        weightController.text = weight;
        heightController.text = height;
        allergiesController.text = allergies;
        medicalConditionsController.text = medicalConditions;

        // notifyListeners();
      } else {
        log("No profile found for user ID: ${_uid}, creating profile.");

        clearControllers();

        name = "";
        age = "";
        gender = "";
        weight = "";
        height = "";
        allergies = "";
        medicalConditions = "";

        hasProfile = false;
      }

      notifyListeners();
    } catch (e) {
      log("${ErrorMessage.LOAD_USER_PROFILE_ERROR}: $e");
      errorMessage = ErrorMessage.LOAD_USER_PROFILE_ERROR;
      notifyListeners();
    }
  }

  Future<void> loadUserProfile(String userId) async {
    try {
      final doc =
          await _firestore.collection("user_profiles").doc(userId).get();

      if (doc.exists) {
        final profile = UserProfile.fromDoc(doc);

        name = profile.name;
        age = profile.age.toString();
        gender = profile.gender;
        weight = profile.weight;
        height = profile.height;
        allergies = profile.allergies.join(', ');
        medicalConditions = profile.medicalConditions.join(', ');

        notifyListeners();
      }
    } catch (e) {
      log("${ErrorMessage.LOAD_USER_PROFILE_ERROR}: $e");
      errorMessage = ErrorMessage.LOAD_USER_PROFILE_ERROR;
      notifyListeners();
    }
  }

  Future<bool> saveProfile() async {
    try {
      isLoading = true;
      notifyListeners();
      _requireAuth();

      log("Creating user profile for user: ${_uid}");
      final profile = UserProfile(
        id: _uid!,
        name: nameController.text,
        age: int.tryParse(ageController.text) ?? 0,
        gender: genderController.text,
        weight: weightController.text,
        height: heightController.text,
        allergies:
            allergiesController.text.split(',').map((e) => e.trim()).toList(),
        medicalConditions:
            medicalConditionsController.text
                .split(',')
                .map((e) => e.trim())
                .toList(),
      );

      await _firestore
          .collection("user_profiles")
          .doc(_uid)
          .set(profile.toMap());

      hasProfile = true;
      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      isLoading = false;
      log("${ErrorMessage.SAVE_USER_PROFILE_ERROR}: $e");
      errorMessage = ErrorMessage.SAVE_USER_PROFILE_ERROR;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile() async {
    try {
      isLoading = true;
      notifyListeners();
      _requireAuth();

      final profile = UserProfile(
        id: _uid!,
        name: nameController.text,
        age: int.tryParse(ageController.text) ?? 0,
        gender: genderController.text,
        weight: weightController.text,
        height: heightController.text,
        allergies:
            allergiesController.text.split(',').map((e) => e.trim()).toList(),
        medicalConditions:
            medicalConditionsController.text
                .split(',')
                .map((e) => e.trim())
                .toList(),
      );

      await _firestore
          .collection("user_profiles")
          .doc(_uid)
          .update(profile.toMap());

      name = nameController.text;
      age = ageController.text;
      gender = genderController.text;
      weight = weightController.text;
      height = heightController.text;
      allergies = allergiesController.text;
      medicalConditions = medicalConditionsController.text;

      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      isLoading = false;
      log("${ErrorMessage.UPDATE_USER_PROFILE_ERROR}: $e");
      errorMessage = ErrorMessage.UPDATE_USER_PROFILE_ERROR;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProfile() async {
    try {
      isLoading = true;
      notifyListeners();

      _requireAuth();

      await _firestore.collection("user_profiles").doc(_uid).delete();

      clearControllers();

      hasProfile = false;
      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      isLoading = false;
      log("${ErrorMessage.DELETE_USER_PROFILE_ERROR}: $e");
      errorMessage = ErrorMessage.DELETE_USER_PROFILE_ERROR;
      notifyListeners();
      return false;
    }
  }

  void _requireAuth() {
    if (_uid == null) {
      hasProfile = false;
      errorMessage = ("User Profile error: ${ErrorMessage.AUTH_ERROR}");
      throw Exception("User Profile error: ${ErrorMessage.AUTH_ERROR}");
    } else {
      log("Authenticated user ID for user profile view: $_uid");
    }
  }
}
