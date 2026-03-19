import 'profile.dart';

class PharmacistProfile extends Profile {
  final String license;
  final String pharmacyName;
  final int experience;

  PharmacistProfile({
    required super.id,
    required super.name,
    required this.license,
    required this.pharmacyName,
    required this.experience,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'license': license,
      'pharmacyName': pharmacyName,
      'experience': experience,
    };
  }

  factory PharmacistProfile.fromMap(Map<String, dynamic> map) {
    return PharmacistProfile(
      id: map['id'],
      name: map['name'],
      license: map['license'] ?? '',
      pharmacyName: map['pharmacyName'] ?? '',
      experience: map['experience'] ?? 0,
    );
  }
}