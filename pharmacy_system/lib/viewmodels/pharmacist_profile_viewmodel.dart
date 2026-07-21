import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/pharmacist_profile.dart';
import '../constants/error_message.dart';

/// for managing pharmacist profile data.
/// It performs CRUD (Create, Read, Update, Delete) operations
/// using Cloud Firestore and maintains the profile state for the UI.
class PharmacistProfileViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final licenseController = TextEditingController();
  final pharmacyNameController = TextEditingController();
  final experienceController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool hasProfile = false;

  String name = '';
  String license = '';
  String pharmacyName = '';
  int experience = 0;

  // User? get _currentUser => FirebaseAuth.instance.currentUser;
  // String? get _uid => _currentUser?.uid;

  /// Checks whether the currently authenticated pharmacist
  /// has an existing profile stored in Firestore.
  Future<void> checkProfileExists() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      hasProfile = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();
    try {
      final doc =
          await _firestore
              .collection('pharmacist_profiles')
              .doc(user.uid)
              .get();
      hasProfile = doc.exists;
    } catch (e) {
      log("${ErrorMessage.LOAD_PROFILE_ERROR}: $e");
      errorMessage = ErrorMessage.LOAD_PROFILE_ERROR;
    } finally {
      isLoading = false;
    }
    notifyListeners();
  }

  /// Retrieves the authenticated pharmacist's profile
  /// from Firestore and populates the UI controllers.
  Future<void> loadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc =
          await _firestore
              .collection('pharmacist_profiles')
              .doc(user.uid)
              .get();

      if (doc.exists) {
        final profile = PharmacistProfile.fromDoc(doc);

        // Cache profile information locally.
        name = profile.name;
        license = profile.license;
        pharmacyName = profile.pharmacyName;
        experience = profile.experience;

        nameController.text = name;
        licenseController.text = license;
        pharmacyNameController.text = pharmacyName;
        experienceController.text = experience.toString();

        hasProfile = true;
      } else {
        hasProfile = false;
      }

      notifyListeners();
    } catch (e) {
      log("${ErrorMessage.LOAD_PROFILE_ERROR}: $e");
      errorMessage = ErrorMessage.LOAD_PROFILE_ERROR;
      notifyListeners();
    }
  }

  /// Creates a new pharmacist profile in Firestore.
  /// This method is called when the pharmacist completes
  /// profile registration for the first time.
  Future<bool> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      isLoading = true;
      notifyListeners();

      final profile = PharmacistProfile(
        id: user.uid,
        name: nameController.text.trim(),
        license: licenseController.text.trim(),
        pharmacyName: pharmacyNameController.text.trim(),
        experience: int.tryParse(experienceController.text.trim()) ?? 0,
      );

      await _firestore
          .collection('pharmacist_profiles')
          .doc(user.uid)
          .set(profile.toMap());

      hasProfile = true;
      await loadProfile();
      return true;
    } catch (e) {
      log("${ErrorMessage.SAVE_PROFILE_ERROR}: $e");
      errorMessage = ErrorMessage.SAVE_PROFILE_ERROR;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Updates an existing pharmacist profile in Firestore.
  Future<bool> updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      isLoading = true;
      notifyListeners();

      final profile = PharmacistProfile(
        id: user.uid,
        name: nameController.text.trim(),
        license: licenseController.text.trim(),
        pharmacyName: pharmacyNameController.text.trim(),
        experience: int.tryParse(experienceController.text.trim()) ?? 0,
      );

      await _firestore
          .collection('pharmacist_profiles')
          .doc(user.uid)
          .update(profile.toMap());

      await loadProfile();
      return true;
    } catch (e) {
      log("${ErrorMessage.UPDATE_PROFILE_ERROR}: $e");
      errorMessage = ErrorMessage.UPDATE_PROFILE_ERROR;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes the pharmacist profile from Firestore
  /// and clears all locally stored profile information.
  Future<bool> deleteProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      isLoading = true;
      notifyListeners();

      await _firestore.collection('pharmacist_profiles').doc(user.uid).delete();

      // reset local state
      name = '';
      license = '';
      pharmacyName = '';
      experience = 0;
      hasProfile = false;

      nameController.clear();
      licenseController.clear();
      pharmacyNameController.clear();
      experienceController.clear();
      notifyListeners();
      return true;
    } catch (e) {
      log("${ErrorMessage.DELETE_PROFILE_ERROR}: $e");
      errorMessage = ErrorMessage.DELETE_PROFILE_ERROR;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Retrieves another pharmacist's profile using
  /// the supplied user ID.
  ///
  /// This method is primarily used when customers
  /// view pharmacist information before consultation.
  Future<void> loadPharmacistById(String userId) async {
    try {
      isLoading = true;
      notifyListeners();

      final doc =
          await _firestore.collection('pharmacist_profiles').doc(userId).get();

      if (doc.exists) {
        final profile = PharmacistProfile.fromDoc(doc);

        name = profile.name;
        license = profile.license;
        pharmacyName = profile.pharmacyName;
        experience = profile.experience;

        hasProfile = true;
      } else {
        hasProfile = false;
      }
    } catch (e) {
      log("${ErrorMessage.LOAD_PROFILE_ERROR}: $e");
      errorMessage = ErrorMessage.LOAD_PROFILE_ERROR;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Releases all TextEditingController resources
  /// when the ViewModel is no longer required.
  @override
  void dispose() {
    nameController.dispose();
    licenseController.dispose();
    pharmacyNameController.dispose();
    experienceController.dispose();
    super.dispose();
  }

  //   void _requireAuth() {
  //   if (_uid == null) {
  //     errorMessage = ("Pharmacist Profile error: ${ErrorMessage.AUTH_ERROR}");
  //     throw Exception("Pharmacist Profile error: ${ErrorMessage.AUTH_ERROR}");
  //   } else {
  //     log("Authenticated user ID for pharmacist profile view: $_uid");
  //   }
  // }
}
