import 'user.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class PharmacistProfile extends User {
  final String license;
  final String pharmacyName;
  final int experience;
  final DateTime? updatedAt;

  PharmacistProfile({
    required super.id,
    required super.name,
    required this.license,
    required this.pharmacyName,
    required this.experience,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'license': license,
      'pharmacyName': pharmacyName,
      'experience': experience,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory PharmacistProfile.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PharmacistProfile(
      id: doc.id,
      name: data['name'] ?? '',
      license: data['license'] ?? '',
      pharmacyName: data['pharmacyName'] ?? '',
      experience: data['experience'] ?? 0,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
