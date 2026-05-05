import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/prescription.dart';
import '../constants/error_message.dart';

class PrescriptionViewModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  List<Prescription> prescriptions = [];
  bool isLoadingPrescription = false;
  String? errorMessage;
  User? get _currentUser => FirebaseAuth.instance.currentUser;
  String? get _uid => _currentUser?.uid;

  //load prescriptions for current user: user_profiles/{userId}/prescriptions
  Future<void> loadPrescriptions() async {
    try {
      _requireAuth();

      isLoadingPrescription = true;
      notifyListeners();

      final snapshot =
          await _firestore
              .collection("user_profiles")
              .doc(_uid)
              .collection("prescriptions")
              .get();

      prescriptions =
          snapshot.docs.map((doc) => Prescription.fromDoc(doc)).toList();
      log("Total presciptions: ${prescriptions.length}");

      isLoadingPrescription = false;
      notifyListeners();
    } catch (e) {
      log("${ErrorMessage.LOAD_PRESCRIPTION_ERROR}: $e");
      errorMessage = ErrorMessage.LOAD_PRESCRIPTION_ERROR;
      isLoadingPrescription = false;
      notifyListeners();
    }
  }

  //load prescriptions for current user: user_profiles/{userId}/prescriptions
  Future<void> loadUserPrescriptions(String userId) async {
    log("Loading user prescriptions from firestore: $userId");
    try {
      isLoadingPrescription = true;
      notifyListeners();

      final snapshot =
          await _firestore
              .collection("user_profiles")
              .doc(userId)
              .collection("prescriptions")
              .get();

      log("Prescriptions count: ${snapshot.docs.length}");

      prescriptions =
          snapshot.docs.map((doc) => Prescription.fromDoc(doc)).toList();

      isLoadingPrescription = false;
      notifyListeners();
    } catch (e) {
      log("${ErrorMessage.LOAD_PRESCRIPTION_ERROR}: $e");
      errorMessage = ErrorMessage.LOAD_PRESCRIPTION_ERROR;
      isLoadingPrescription = false;
      notifyListeners();
    }
  }

  //add: user_profiles/{userId}/prescriptions
  Future<void> storePrescription(Prescription prescription) async {
    try {
      _requireAuth();
      final userDoc =
          await _firestore.collection("user_profiles").doc(_uid).get();

      final userName = userDoc.data()?['name'] ?? "Unknown";

      final updatedPrescriptions = prescription.copyWith(
        addedBy: _uid,
        addedByName: userName,
      );
      log(
        "Prescription added by: $userName, prescription details: ${updatedPrescriptions.toMap()}",
      );

      await _firestore
          .collection("user_profiles")
          .doc(_uid)
          .collection("prescriptions")
          .add(updatedPrescriptions.toMap());

      await loadPrescriptions();
    } catch (e) {
      log("${ErrorMessage.STORE_PRESCRIPTION_ERROR}: $e");
      errorMessage = ErrorMessage.STORE_PRESCRIPTION_ERROR;
      notifyListeners();
    }
  }

  //add: user_profiles/{userId}/prescriptions/{prescriptionId}
  Future<void> storeUserPrescription(
    String userId,
    Prescription prescription,
  ) async {
    try {
      _requireAuth();
      final userDoc =
          await _firestore.collection("pharmacist_profiles").doc(_uid).get();

      final userName = userDoc.data()?['name'] ?? "Unknown";

      final updatedPrescriptions = prescription.copyWith(
        addedBy: _uid,
        addedByName: userName,
      );
      log(
        "Prescription added by: $userName, prescription details: ${updatedPrescriptions.toMap()}",
      );

      await _firestore
          .collection("user_profiles")
          .doc(userId)
          .collection("prescriptions")
          .add(updatedPrescriptions.toMap());

      await loadUserPrescriptions(userId);
    } catch (e) {
      log("${ErrorMessage.STORE_PRESCRIPTION_ERROR}: $e");
      errorMessage = ErrorMessage.STORE_PRESCRIPTION_ERROR;
      notifyListeners();
    }
  }

  //update: user_profiles/{userId}/prescriptions/{prescriptionId}
  Future<void> updatePrescription(Prescription prescription) async {
    try {
      _requireAuth();
      final userDoc =
          await _firestore.collection("user_profiles").doc(_uid).get();

      final userName = userDoc.data()?['name'] ?? "Unknown";

      final updatedPrescription = prescription.copyWith(
        addedBy: _uid,
        addedByName: userName,
      );
      log("Updating prescription: ${updatedPrescription.toMap()}");

      await _firestore
          .collection("user_profiles")
          .doc(_uid)
          .collection("prescriptions")
          .doc(prescription.prescriptionId)
          .update(updatedPrescription.toMap(isUpdate: true));

      log("Prescriptions successfully updated");
      await loadPrescriptions();
    } catch (e) {
      log("${ErrorMessage.UPDATE_PRESCRIPTION_ERROR}: $e");
      errorMessage = ErrorMessage.UPDATE_PRESCRIPTION_ERROR;
      notifyListeners();
    }
  }

  //update: user_profiles/{userId}/prescriptions/{prescriptionId}
  Future<void> updateUserPrescription(
    String userId,
    Prescription prescription,
  ) async {
    try {
      _requireAuth();
      final userDoc =
          await _firestore.collection("pharmacist_profiles").doc(_uid).get();

      final userName = userDoc.data()?['name'] ?? "Unknown";
      final updatedPrescription = prescription.copyWith(
        addedBy: _uid,
        addedByName: userName,
      );
      log("Updating prescription: ${updatedPrescription.toMap()}");

      await _firestore
          .collection("user_profiles")
          .doc(userId)
          .collection("prescriptions")
          .doc(prescription.prescriptionId)
          .update(updatedPrescription.toMap());
      await loadUserPrescriptions(userId);
    } catch (e) {
      log("${ErrorMessage.UPDATE_PRESCRIPTION_ERROR}: $e");
      errorMessage = ErrorMessage.UPDATE_PRESCRIPTION_ERROR;
      notifyListeners();
    }
  }

  //delete: user_profiles/{userId}/prescriptions/{prescriptionId}
  Future<void> deletePrescription(String id) async {
    try {
      _requireAuth();

      await _firestore
          .collection("user_profiles")
          .doc(_uid)
          .collection("prescriptions")
          .doc(id)
          .delete();

      log("Prescriptions deleted");
      await loadPrescriptions();
    } catch (e) {
      log("${ErrorMessage.DELETE_PRESCRIPTION_ERROR}: $e");
      errorMessage = ErrorMessage.DELETE_PRESCRIPTION_ERROR;
      notifyListeners();
    }
  }

  //delete: user_profiles/{userId}/prescriptions/{prescriptionId}
  Future<void> deleteUserPrescription(String userId, String id) async {
    try {
      await _firestore
          .collection("user_profiles")
          .doc(userId)
          .collection("prescriptions")
          .doc(id)
          .delete();

      await loadUserPrescriptions(userId);
    } catch (e) {
      log("${ErrorMessage.DELETE_PRESCRIPTION_ERROR}: $e");
      errorMessage = ErrorMessage.DELETE_PRESCRIPTION_ERROR;
      notifyListeners();
    }
  }

  void _requireAuth() {
    if (_uid == null) {
      errorMessage =
          ("Prescription operations error: ${ErrorMessage.AUTH_ERROR}");
      throw Exception(
        "Prescription operations error: ${ErrorMessage.AUTH_ERROR}",
      );
    } else {
      log("Authenticated user ID for prescription view: $_uid");
    }
  }
}
