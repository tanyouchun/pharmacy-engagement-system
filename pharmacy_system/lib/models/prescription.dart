import 'package:cloud_firestore/cloud_firestore.dart';

class Prescription {
  final String prescriptionId;
  final String medicineName;
  final String frequency;
  final String notes;
  final String addedBy;
  final String addedByName;
  final DateTime? issueDate;

  Prescription({
    required this.prescriptionId,
    required this.medicineName,
    required this.frequency,
    required this.notes,
    required this.addedBy,
    required this.addedByName,
    this.issueDate,
  });

  factory Prescription.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Prescription(
      prescriptionId: doc.id,
      medicineName: data['medicineName'] ?? '',
      frequency: data['frequency'] ?? '',
      notes: data['notes'] ?? '',
      addedBy: data['addedBy'] ?? '',
      addedByName: data['addedByName'] ?? '',
      issueDate: (data['issueDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    return {
      "medicineName": medicineName,
      "frequency": frequency,
      "notes": notes,
      "addedBy": addedBy,
      "addedByName": addedByName,
      if (!isUpdate) "issueDate": FieldValue.serverTimestamp(),
      if (isUpdate) "updatedAt": FieldValue.serverTimestamp(),
    };
  }

  Prescription copyWith({
    String? medicineName,
    String? frequency,
    String? notes,
    String? addedBy,
    String? addedByName,
  }) {
    return Prescription(
      prescriptionId: prescriptionId,
      medicineName: medicineName ?? this.medicineName,
      frequency: frequency ?? this.frequency,
      notes: notes ?? this.notes,
      addedBy: addedBy ?? this.addedBy,
      addedByName: addedByName ?? this.addedByName,
      issueDate: issueDate,
    );
  }
}
