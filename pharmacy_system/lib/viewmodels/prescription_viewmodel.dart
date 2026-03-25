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

  //add: user_profiles/{userId}/prescriptions
  Future<void> addPrescription(String name, String notes) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      errorMessage = "User not logged in";
      notifyListeners();
      return;
    }
    final userDoc =
        await _firestore.collection("user_profiles").doc(user.uid).get();

    final userName = userDoc.data()?['name'] ?? "Unknown";

    log("AddedBy: $userName");

    final prescription = Prescription(
      id: '',
      name: name,
      notes: notes,
      addedBy: user.uid,
      addedByName: userName,
    );

    await _firestore
        .collection("user_profiles")
        .doc(user.uid)
        .collection("prescriptions")
        .add(prescription.toMap());

    await loadPrescriptions();
  }

  //update: user_profiles/{userId}/prescriptions/{prescriptionId}
  Future<void> updatePrescription(String id, String name, String notes) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;
    final userDoc =
        await _firestore.collection("user_profiles").doc(user.uid).get();

    final userName = userDoc.data()?['name'] ?? "Unknown";

    final updated = Prescription(
      id: id,
      name: name,
      notes: notes,
      addedBy: user.uid,
      addedByName: userName,
    );

    await _firestore
        .collection("user_profiles")
        .doc(user.uid)
        .collection("prescriptions")
        .doc(id)
        .update(updated.toMap(isUpdate: true));

    await loadPrescriptions();
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

    await loadPrescriptions();
  }
}
