import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';

/// Model representing a user profile managed by the administrator.
///
/// This model extends the base User model by including additional
/// administrative information used for account management.
class AdminProfile extends User {
  final String role;
  final String? email;
  final bool isBlocked;
  final bool isPermanentBan;
  final DateTime? suspendUntil;
  final String? approvalStatus;

  AdminProfile({
    required super.id,
    required super.name,
    this.role = 'user',
    this.email,
    this.isBlocked = false,
    this.isPermanentBan = false,
    this.suspendUntil,
    this.approvalStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      if (email != null) 'email': email,
      'isBlocked': isBlocked,
      'isPermanentBan': isPermanentBan,
      if (suspendUntil != null) 'suspendUntil': suspendUntil,
      if (approvalStatus != null) 'approvalStatus': approvalStatus,
    };
  }

  factory AdminProfile.fromMap(Map<String, dynamic> map, {String? id}) {
    return AdminProfile(
      id: id ?? map['id'] as String,
      name: map['name'] as String,
      role: map['role'] as String? ?? 'user',
      email: map['email'] as String?,
      isBlocked: map['isBlocked'] as bool? ?? false,
      isPermanentBan: map['isPermanentBan'] as bool? ?? false,
      suspendUntil:
          map['suspendUntil'] != null
              ? (map['suspendUntil'] as Timestamp).toDate()
              : null,
      approvalStatus: map['approvalStatus'] as String?,
    );
  }

  factory AdminProfile.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return AdminProfile.fromMap(data ?? {}, id: doc.id);
  }
}
