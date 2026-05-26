import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy_system/models/prescription.dart';
import '../services/openai_service.dart';
import '../models/user_profile.dart';
import '../constants/error_message.dart';

class UserProfileViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OpenAIService _openAIService = OpenAIService();

  // String name = "";
  // String age = "";
  // String gender = "";
  // String weight = "";
  // String height = "";
  // String allergies = "";
  // String medicalConditions = "";
  UserProfile? profile;

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

  Future<void> checkProfileExists() async {
    log("Checking user profile existence for UID: ${_uid}");
    _requireAuth();

    final doc = await _firestore.collection("user_profiles").doc(_uid).get();

    hasProfile = doc.exists;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    try {
      _requireAuth();

      final doc = await _firestore.collection("user_profiles").doc(_uid).get();

      if (doc.exists) {
        profile = UserProfile.fromDoc(doc);

        hasProfile = true;

        nameController.text = profile!.name;
        ageController.text = profile!.age.toString();
        genderController.text = profile!.gender;
        weightController.text = profile!.weight;
        heightController.text = profile!.height;
        allergiesController.text = profile!.allergies.join(", ");
        medicalConditionsController.text = profile!.medicalConditions.join(
          ", ",
        );
      } else {
        profile = null;
        hasProfile = false;
        clearControllers();
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
        profile = UserProfile.fromDoc(doc);

        hasProfile = true;
      } else {
        profile = null;
        hasProfile = false;
      }

      notifyListeners();
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

      final newProfile = UserProfile(
        id: _uid!,
        name: nameController.text.trim(),
        age: int.tryParse(ageController.text) ?? 0,
        gender: genderController.text.trim(),
        weight: weightController.text.trim(),
        height: heightController.text.trim(),
        allergies:
            allergiesController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
        medicalConditions:
            medicalConditionsController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
      );

      await _firestore
          .collection("user_profiles")
          .doc(_uid)
          .set(newProfile.toMap());

      profile = newProfile;
      hasProfile = true;

      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = ErrorMessage.SAVE_USER_PROFILE_ERROR;

      log("${ErrorMessage.SAVE_USER_PROFILE_ERROR}: $e");

      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile() async {
    try {
      isLoading = true;
      notifyListeners();

      _requireAuth();

      if (profile == null) {
        throw Exception("Profile does not exist");
      }

      final updatedProfile = profile!.copyWith(
        name: nameController.text.trim(),
        age: int.tryParse(ageController.text) ?? 0,
        gender: genderController.text.trim(),
        weight: weightController.text.trim(),
        height: heightController.text.trim(),
        allergies:
            allergiesController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
        medicalConditions:
            medicalConditionsController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
      );

      await _firestore
          .collection("user_profiles")
          .doc(_uid)
          .update(updatedProfile.toMap());

      profile = updatedProfile;

      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = ErrorMessage.UPDATE_USER_PROFILE_ERROR;

      log("${ErrorMessage.UPDATE_USER_PROFILE_ERROR}: $e");

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

  Future<String> generateAIAnalysis({
    required String name,
    required String age,
    required String gender,
    required String weight,
    required String height,
    required String allergies,
    required String medicalConditions,
    required List<Prescription> prescriptions,
  }) async {
    try {
      // _requireAuth();

      // final prescriptionSnapshot =
      //     await _firestore
      //         .collection("user_profiles")
      //         .doc(_uid)
      //         .collection("prescriptions")
      //         .orderBy("issueDate", descending: true)
      //         .get();

      // final prescriptions =
      //     prescriptionSnapshot.docs
      //         .map((doc) => Prescription.fromDoc(doc))
      //         .toList();

      String prescriptionText = "";

      for (final p in prescriptions) {
        prescriptionText +=
            "- Medicine: ${p.medicineName}\n"
            "- Frequency: ${p.frequency}\n"
            "- Notes: ${p.notes}\n\n";
      }

      final profileText = """
        Name: $name
        Age: $age
        Gender: $gender
        Weight: $weight
        Height: $height
        Allergies: $allergies
        Medical Conditions: $medicalConditions
        """;

      final result = await _openAIService.sendMessage(
        promptKey: "analysis_prompt",
        messages: [
          {
            "role": "user",
            "content": """
            PATIENT PROFILE:
            $profileText

            PRESCRIPTION HISTORY:
            $prescriptionText
            """,
          },
        ],
      );

      return result;
    } catch (e) {
      log("AI Analysis Error: $e");
      return "Unable to generate AI analysis.";
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
