import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/prescription.dart';
import '../constants/error_message.dart';

/// PrescriptionViewModel manages all prescription-related operations
/// between the Flutter user interface and Firebase Firestore database.
///
/// - Retrieving prescription records from Firestore
/// - Adding new prescriptions
/// - Updating existing prescriptions
/// - Deleting prescriptions
/// - Managing prescription visibility settings
/// - Handling authentication validation and error messages
class PrescriptionViewModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  List<Prescription> prescriptions = [];
  bool isLoadingPrescription = false;
  String? errorMessage;
  User? get _currentUser => FirebaseAuth.instance.currentUser;
  String? get _uid => _currentUser?.uid;
  String? get uid => _uid;

  bool isPrescriptionVisible = true;
  bool isUpdatingVisibility = false;

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

  /// Loads the current prescription visibility setting of a user.
  ///
  /// The visibility setting determines whether pharmacists are allowed
  /// to access the patient's prescription information.
  Future<void> loadPrescriptionVisibility(String userId) async {
    try {
      final doc =
          await _firestore.collection("user_profiles").doc(userId).get();

      isPrescriptionVisible = doc.data()?['prescriptionVisibility'] ?? true;

      notifyListeners();
    } catch (e) {
      log("Load prescription visibility error: $e");
    }
  }

  /// Updates prescription visibility permission in Firestore.
  ///
  /// This allows patients to control whether pharmacists can view
  /// their prescription records.
  Future<void> updatePrescriptionVisibility(bool value) async {
    try {
      _requireAuth();

      isUpdatingVisibility = true;
      notifyListeners();
      log("Updating prescription visibility to: $value for user: $_uid");

      await _firestore.collection("user_profiles").doc(_uid).update({
        "prescriptionVisibility": value,
      });

      isPrescriptionVisible = value;

      isUpdatingVisibility = false;
      notifyListeners();
    } catch (e) {
      isUpdatingVisibility = false;
      notifyListeners();

      log("Update prescription visibility error: $e");
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

  /// Adds a new prescription for the current user.
  ///
  /// Firestore path:
  /// user_profiles/{userId}/prescriptions
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

  /// Allows pharmacists to add prescriptions for customers.
  ///
  /// Firestore path:
  /// user_profiles/{userId}/prescriptions
  ///
  /// The pharmacist identity is stored as the prescription creator
  /// for accountability and tracking purposes.
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

  /// Updates an existing prescription belonging to the current user.
  ///
  /// Firestore path:
  /// user_profiles/{userId}/prescriptions/{prescriptionId}
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

  /// Updates a customer's prescription record by pharmacist.
  ///
  /// Used when pharmacists modify prescription information
  /// on behalf of customers.
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

  /// Deletes a prescription belonging to the current user.
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

  /// Deletes a customer's prescription record.
  ///
  /// Used by pharmacists when managing customer prescriptions.
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

  /// Checks whether a user is authenticated before performing
  /// prescription-related operations.
  ///
  /// Prevents unauthorized access to prescription data.
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
