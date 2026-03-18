class UserProfile {
  final String id; // Unique identifier for the user
  final String name;
  final int age;
  final String role; // e.g., "patient", "pharmacist"
  final String gender;
  final String healthInfo;
  final String height;
  final String weight;
  final String allergies;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.role,
    required this.gender,
    this.healthInfo = '',
    this.height = '',
    this.weight = '',
    this.allergies = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'role': role,
      'gender': gender,
    };
  }
}