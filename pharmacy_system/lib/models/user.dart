import 'package:cloud_firestore/cloud_firestore.dart';

abstract class User {
  final String id;
  final String name;

  User({required this.id, required this.name});
}

class UserAccount extends User {
  final String email;
  final String role;
  final String approvalStatus;
  final bool isBlocked;
  final bool isPermanentBan;
  final DateTime? suspendUntil;
  final int reportCount;
  final DateTime? createdAt;

  UserAccount({
    required super.id,
    required super.name,
    required this.email,
    this.role = 'user',
    this.approvalStatus = 'approved',
    this.isBlocked = false,
    this.isPermanentBan = false,
    this.suspendUntil,
    this.reportCount = 0,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'approvalStatus': approvalStatus,
      'isBlocked': isBlocked,
      'isPermanentBan': isPermanentBan,
      if (suspendUntil != null) 'suspendUntil': suspendUntil,
      'reportCount': reportCount,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'email': email,
      'role': role,
      'approvalStatus': approvalStatus,
      'isBlocked': isBlocked,
      'isPermanentBan': isPermanentBan,
      'suspendUntil': suspendUntil,
      'reportCount': reportCount,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserAccount.fromMap(Map<String, dynamic> map, {required String id}) {
    return UserAccount(
      id: id,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'user',
      approvalStatus: map['approvalStatus'] as String? ?? 'approved',
      isBlocked: map['isBlocked'] as bool? ?? false,
      isPermanentBan: map['isPermanentBan'] as bool? ?? false,
      suspendUntil:
          map['suspendUntil'] is Timestamp
              ? (map['suspendUntil'] as Timestamp).toDate()
              : null,
      reportCount: map['reportCount'] as int? ?? 0,
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : null,
    );
  }

  factory UserAccount.fromSnapshot(DocumentSnapshot doc) {
    return UserAccount.fromMap(doc.data() as Map<String, dynamic>, id: doc.id);
  }

  factory UserAccount.newUser({
    required String id,
    required String email,
    required String name,
    required bool isPharmacist,
  }) {
    return UserAccount(
      id: id,
      name: name,
      email: email,
      role: isPharmacist ? 'pharmacist' : 'user',
      approvalStatus: isPharmacist ? 'pending' : 'approved',
      isBlocked: false,
      isPermanentBan: false,
      reportCount: 0,
    );
  }

  UserAccount copyWith({
    String? name,
    String? email,
    String? role,
    String? approvalStatus,
    bool? isBlocked,
    bool? isPermanentBan,
    DateTime? suspendUntil,
    int? reportCount,
    DateTime? createdAt,
  }) {
    return UserAccount(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      isBlocked: isBlocked ?? this.isBlocked,
      isPermanentBan: isPermanentBan ?? this.isPermanentBan,
      suspendUntil: suspendUntil ?? this.suspendUntil,
      reportCount: reportCount ?? this.reportCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
