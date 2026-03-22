import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      isLoading = true;
      notifyListeners();

      final doc =
          await _firestore
              .collection('pharmacist_profiles')
              .doc(user.uid)
              .get();

      if (doc.exists) {
        final data = doc.data() ?? {};
        name = (data['name'] ?? '').toString();
        license = (data['license'] ?? '').toString();
        pharmacyName = (data['pharmacyName'] ?? '').toString();
        experience =
            (data['experience'] is int)
                ? data['experience'] as int
                : int.tryParse((data['experience'] ?? '0').toString()) ?? 0;

        nameController.text = name;
        licenseController.text = license;
        pharmacyNameController.text = pharmacyName;
        experienceController.text = experience.toString();

        hasProfile = true;
      } else {
        hasProfile = false;
      }
    } catch (e) {
      errorMessage = 'Failed to load profile: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      isLoading = true;
      notifyListeners();

      await _firestore.collection('pharmacist_profiles').doc(user.uid).set({
        'id': user.uid,
        'name': nameController.text.trim(),
        'license': licenseController.text.trim(),
        'pharmacyName': pharmacyNameController.text.trim(),
        'experience': int.tryParse(experienceController.text.trim()) ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });

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

      await _firestore.collection('pharmacist_profiles').doc(user.uid).update({
        'name': nameController.text.trim(),
        'license': licenseController.text.trim(),
        'pharmacyName': pharmacyNameController.text.trim(),
        'experience': int.tryParse(experienceController.text.trim()) ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });

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

      return true; // ✅ success
    } catch (e) {
      errorMessage = 'Failed to delete profile: $e';
      return false; // ❌ failed
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
