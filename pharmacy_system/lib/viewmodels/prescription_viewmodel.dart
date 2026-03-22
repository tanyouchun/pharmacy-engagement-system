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
        snapshot.docs
            .map((doc) => Prescription.fromMap(doc.id, doc.data()))
            .toList();

    isLoadingPrescription = false;
    notifyListeners();
  }

  //add: user_profiles/{userId}/prescriptions
  Future<void> addPrescription(String name, String notes) async {
    final user = FirebaseAuth.instance.currentUser;

    await _firestore
        .collection("user_profiles")
        .doc(user!.uid)
        .collection("prescriptions")
        .add({"name": name, "notes": notes, "date": DateTime.now()});

    await loadPrescriptions();
  }

  //update: user_profiles/{userId}/prescriptions/{prescriptionId}
  Future<void> updatePrescription(String id, String name, String notes) async {
    final user = FirebaseAuth.instance.currentUser;

    await _firestore
        .collection("user_profiles")
        .doc(user!.uid)
        .collection("prescriptions")
        .doc(id)
        .update({"name": name, "notes": notes});

    await loadPrescriptions();
  }

  //delete: user_profiles/{userId}/prescriptions/{prescriptionId}
  Future<void> deletePrescription(String id) async {
    final user = FirebaseAuth.instance.currentUser;

    await _firestore
        .collection("user_profiles")
        .doc(user!.uid)
        .collection("prescriptions")
        .doc(id)
        .delete();

    await loadPrescriptions();
  }
}
