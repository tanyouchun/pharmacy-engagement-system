import 'user.dart';

class AdminProfile extends User {
  final String roleLevel; // e.g. superadmin, moderator

  AdminProfile({
    required super.id,
    required super.name,
    required this.roleLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'roleLevel': roleLevel,
    };
  }

  factory AdminProfile.fromMap(Map<String, dynamic> map) {
    return AdminProfile(
      id: map['id'],
      name: map['name'],
      roleLevel: map['roleLevel'] ?? 'admin',
    );
  }
}