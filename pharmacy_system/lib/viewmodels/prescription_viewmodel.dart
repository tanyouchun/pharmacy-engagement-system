import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/prescription.dart';

class PrescriptionViewModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  List<Prescription> prescriptions = [];
  bool isLoadingPrescription = false;
  String? errorMessage;

  Future<void> loadPrescriptions() async {
    isLoadingPrescription = true;
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;

    final snapshot =
        await _firestore
            .collection("prescriptions")
            .doc(user!.uid)
            .collection("user_prescriptions")
            .get();

    prescriptions =
        snapshot.docs
            .map((doc) => Prescription.fromMap(doc.id, doc.data()))
            .toList();

    isLoadingPrescription = false;
    notifyListeners();
  }

  Future<void> addPrescription(String name, String notes) async {
    final user = FirebaseAuth.instance.currentUser;

    await _firestore
        .collection("prescriptions")
        .doc(user!.uid)
        .collection("user_prescriptions")
        .add({"name": name, "notes": notes, "date": DateTime.now().toString()});

    await loadPrescriptions();
  }

  Future<void> updatePrescription(String id, String name, String notes) async {
    final user = FirebaseAuth.instance.currentUser;

    await _firestore
        .collection("prescriptions")
        .doc(user!.uid)
        .collection("user_prescriptions")
        .doc(id)
        .update({"name": name, "notes": notes});

    await loadPrescriptions();
  }

  Future<void> deletePrescription(String id) async {
    final user = FirebaseAuth.instance.currentUser;

    await _firestore
        .collection("prescriptions")
        .doc(user!.uid)
        .collection("user_prescriptions")
        .doc(id)
        .delete();

    await loadPrescriptions();
  }
}
