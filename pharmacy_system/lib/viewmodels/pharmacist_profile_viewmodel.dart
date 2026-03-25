import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/pharmacist_profile.dart';

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
    } finally {
      isLoading = false;
    }
    notifyListeners();
  }

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
      errorMessage = 'Failed to load profile';
      notifyListeners();
    }
  }

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
      errorMessage = 'Failed to save profile: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

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
      errorMessage = 'Failed to update profile: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

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
      errorMessage = 'Failed to delete profile: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

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
      log("Error loading pharmacist profile: $e");
      errorMessage = 'Failed to load pharmacist: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    licenseController.dispose();
    pharmacyNameController.dispose();
    experienceController.dispose();
    super.dispose();
  }
}
