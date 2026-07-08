import 'package:cloud_firestore/cloud_firestore.dart';

class Prescription {
  final String prescriptionId;
  final String medicationName;
  final String strength;
  final String dose;
  final String frequency;
  final int duration;
  final int quantity;
  final String notes;
  final String addedBy;
  final String addedByName;
  final DateTime? issueDate;
  final bool lowMedicationAlertSent;

  Prescription({
    required this.prescriptionId,
    required this.medicationName,
    required this.strength,
    required this.dose,
    required this.frequency,
    required this.duration,
    this.quantity = 0,
    required this.notes,
    required this.addedBy,
    required this.addedByName,
    this.issueDate,
    this.lowMedicationAlertSent = false,
  });

  factory Prescription.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Prescription(
      prescriptionId: doc.id,
      medicationName: data['medicationName'] ?? '',
      strength: data['strength'] ?? '',
      dose: data['dose'] ?? '',
      frequency: data['frequency'] ?? '',
      duration: data['duration'] ?? 0,
      quantity: data['quantity'] ?? data['duration'] ?? 0,
      notes: data['notes'] ?? '',
      addedBy: data['addedBy'] ?? '',
      addedByName: data['addedByName'] ?? '',
      issueDate: (data['issueDate'] as Timestamp?)?.toDate(),
      lowMedicationAlertSent: data['lowMedicationAlertSent'] ?? false,
    );
  }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    return {
      "medicationName": medicationName,
      "strength": strength,
      "dose": dose,
      "frequency": frequency,
      "duration": duration,
      "quantity": quantity > 0 ? quantity : duration,
      "notes": notes,
      "addedBy": addedBy,
      "addedByName": addedByName,
      "lowMedicationAlertSent": lowMedicationAlertSent,
      if (!isUpdate) "issueDate": FieldValue.serverTimestamp(),
      if (isUpdate) "updatedAt": FieldValue.serverTimestamp(),
    };
  }

  Prescription copyWith({
    String? medicationName,
    String? strength,
    String? dose,
    String? frequency,
    int? duration,
    int? quantity,
    String? notes,
    String? addedBy,
    String? addedByName,
    bool? lowMedicationAlertSent,
  }) {
    return Prescription(
      prescriptionId: prescriptionId,
      medicationName: medicationName ?? this.medicationName,
      strength: strength ?? this.strength,
      dose: dose ?? this.dose,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      addedBy: addedBy ?? this.addedBy,
      addedByName: addedByName ?? this.addedByName,
      issueDate: issueDate,
      lowMedicationAlertSent:
          lowMedicationAlertSent ?? this.lowMedicationAlertSent,
    );
  }
}
