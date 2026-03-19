import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pharmacist_profile.dart';

class PharmacistViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<PharmacistProfile> pharmacists = [];
  List<PharmacistProfile> filtered = [];

  Future<void> loadPharmacists() async {
    final snapshot =
        await _firestore.collection('pharmacist_profiles').get();

    pharmacists = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return PharmacistProfile.fromMap(data);
    }).toList();

    filtered = pharmacists;
    notifyListeners();
  }

  void search(String query) {
    if (query.isEmpty) {
      filtered = pharmacists;
    } else {
      filtered = pharmacists
          .where((p) =>
              p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}