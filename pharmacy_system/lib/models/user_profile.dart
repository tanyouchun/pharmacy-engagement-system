import 'user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile extends User {
  final int age;
  final String gender;
  final String height;
  final String weight;
  final List<String> allergies;
  final List<String> medicalConditions;
  final DateTime? updatedAt;

  UserProfile({
    required super.id,
    required super.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.allergies,
    required this.medicalConditions,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
      "updatedAt": FieldValue.serverTimestamp(),
    };
  }

  factory UserProfile.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserProfile(
      id: doc.id,
      name: data["name"] ?? "",
      age: data["age"] ?? 0,
      gender: data["gender"] ?? "",
      weight: data["weight"] ?? "",
      height: data["height"] ?? "",
      medicalConditions: List<String>.from(data["medicalConditions"] ?? []),
      allergies: List<String>.from(data["allergies"] ?? []),
      updatedAt: (data["updatedAt"] as Timestamp?)?.toDate(),
    );
  }

  UserProfile copyWith({
    String? name,
    int? age,
    String? gender,
    String? weight,
    String? height,
    List<String>? medicalConditions,
    List<String>? allergies,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      updatedAt: updatedAt,
    );
  }
}
