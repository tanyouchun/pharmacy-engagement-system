import 'profile.dart';

class UserProfile extends Profile {
  final int age;
  final String gender;
  final String height;
  final String weight;
  final String allergies;

  UserProfile({
    required super.id,
    required super.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.allergies,
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
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      height: map['height'] ?? '',
      weight: map['weight'] ?? '',
      allergies: map['allergies'] ?? '',
    );
  }
}