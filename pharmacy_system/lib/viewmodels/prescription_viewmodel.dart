import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/prescription.dart';

class PrescriptionViewModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  List<Prescription> prescriptions = [];
  bool isLoadingPrescription = false;
  String? errorMessage;

  //load prescriptions for current user: user_profiles/{userId}/prescriptions
  Future<void> loadPrescriptions() async {
    isLoadingPrescription = true;
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;

    final snapshot =
        await _firestore
            .collection("user_profiles")
            .doc(user!.uid)
            .collection("prescriptions")
            .get();

    prescriptions =
        snapshot.docs.map((doc) => Prescription.fromDoc(doc)).toList();
    log("Total presciptions: ${prescriptions.length}");

    isLoadingPrescription = false;
    notifyListeners();
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
      log("ERROR: $e");
      errorMessage = "Failed to load prescriptions";
      isLoadingPrescription = false;
      notifyListeners();
    }
  }

  //add: user_profiles/{userId}/prescriptions
  Future<void> storePrescription(Prescription prescription) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      errorMessage = "User not logged in";
      notifyListeners();
      return;
    }
    final userDoc =
        await _firestore.collection("user_profiles").doc(user.uid).get();

    final userName = userDoc.data()?['name'] ?? "Unknown";

    final updatedPrescriptions = prescription.copyWith(
      addedBy: user.uid,
      addedByName: userName,
    );
    log(
      "Prescription added by: $userName, prescription details: ${updatedPrescriptions.toMap()}",
    );

    await _firestore
        .collection("user_profiles")
        .doc(user.uid)
        .collection("prescriptions")
        .add(updatedPrescriptions.toMap());

    await loadPrescriptions();
  }

  //add: user_profiles/{userId}/prescriptions/{prescriptionId}
  Future<void> storeUserPrescription(
    String userId,
    Prescription prescription,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      errorMessage = "Pharmacist not logged in";
      return;
    }
    final userDoc =
        await _firestore.collection("pharmacist_profiles").doc(user.uid).get();

    final userName = userDoc.data()?['name'] ?? "Unknown";

    final updatedPrescriptions = prescription.copyWith(
      addedBy: user.uid,
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
  }

  //update: user_profiles/{userId}/prescriptions/{prescriptionId}
  Future<void> updatePrescription(Prescription prescription) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;
    final userDoc =
        await _firestore.collection("user_profiles").doc(user.uid).get();

    final userName = userDoc.data()?['name'] ?? "Unknown";

    final updatedPrescription = prescription.copyWith(
      addedBy: user.uid,
      addedByName: userName,
    );
    log("Updating prescription: ${updatedPrescription.toMap()}");

    await _firestore
        .collection("user_profiles")
        .doc(user.uid)
        .collection("prescriptions")
        .doc(prescription.prescriptionId)
        .update(updatedPrescription.toMap(isUpdate: true));

    log("Prescriptions successfully updated");
    await loadPrescriptions();
  }

  //update: user_profiles/{userId}/prescriptions/{prescriptionId}
  Future<void> updateUserPrescription(
    String userId,
    Prescription prescription,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      errorMessage = "Pharmacist not logged in";
      return;
    }
    final userDoc =
        await _firestore.collection("pharmacist_profiles").doc(user.uid).get();

    final userName = userDoc.data()?['name'] ?? "Unknown";
    final updatedPrescription = prescription.copyWith(
      addedBy: user.uid,
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
  }

  //delete: user_profiles/{userId}/prescriptions/{prescriptionId}
  Future<void> deletePrescription(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore
        .collection("user_profiles")
        .doc(user.uid)
        .collection("prescriptions")
        .doc(id)
        .delete();

    log("Prescriptions deleted");
    await loadPrescriptions();
  }

  //delete: user_profiles/{userId}/prescriptions/{prescriptionId}
  Future<void> deleteUserPrescription(String userId, String id) async {
    await _firestore
        .collection("user_profiles")
        .doc(userId)
        .collection("prescriptions")
        .doc(id)
        .delete();

    await loadUserPrescriptions(userId);
  }
}
