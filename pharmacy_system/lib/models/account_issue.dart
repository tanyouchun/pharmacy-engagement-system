import 'package:cloud_firestore/cloud_firestore.dart';

class AccountIssueReport {
  final String? id;
  final String reportedUserId;
  final String reportedName;
  final String reportedRole;
  final String? reportedBy;
  final String reason;
  final String status;
  final DateTime? createdAt;

  AccountIssueReport({
    this.id,
    required this.reportedUserId,
    required this.reportedName,
    required this.reportedRole,
    required this.reportedBy,
    required this.reason,
    required this.status,
    this.createdAt,
  });

  /// 🔹 Convert model → Firestore
  Map<String, dynamic> toMap() {
    return {
      "reportedUserId": reportedUserId,
      "reportedName": reportedName,
      "reportedRole": reportedRole,
      "reportedBy": reportedBy,
      "reason": reason,
      "status": status,
      "createdAt": FieldValue.serverTimestamp(),
    };
  }

  /// 🔹 Convert Firestore → model
  factory AccountIssueReport.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AccountIssueReport(
      id: doc.id,
      reportedUserId: data["reportedUserId"] ?? "",
      reportedName: data["reportedName"] ?? "",
      reportedRole: data["reportedRole"] ?? "",
      reportedBy: data["reportedBy"],
      reason: data["reason"] ?? "",
      status: data["status"] ?? "pending",
      createdAt: (data["createdAt"] as Timestamp?)?.toDate(),
    );
  }
}