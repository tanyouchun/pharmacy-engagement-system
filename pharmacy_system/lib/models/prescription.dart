import 'package:cloud_firestore/cloud_firestore.dart';

class Prescription {
  final String id;
  final String name;
  final String notes;
  final String addedBy;
  final String addedByName;
  final DateTime? date;

  Prescription({
    required this.id,
    required this.name,
    required this.notes,
    required this.addedBy,
    required this.addedByName,
    this.date,
  });

  factory Prescription.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Prescription(
      id: doc.id,
      name: data['name'] ?? '',
      notes: data['notes'] ?? '',
      addedBy: data['addedBy'] ?? '',
      addedByName: data['addedByName'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate(),
    );
  }

  // factory Prescription.fromMap(String id, Map<String, dynamic> data) {
  //   return Prescription(
  //     id: id,
  //     name: data['name'] ?? '',
  //     notes: data['notes'] ?? '',
  //     addedBy: data['addedBy'] ?? '',
      
  //     date:
  //         (data['date'] is Timestamp)
  //             ? (data['date'] as Timestamp).toDate()
  //             : data['date'] as DateTime?,
  //   );
  // }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    return {
      "name": name,
      "notes": notes,
      "addedBy": addedBy,
      "addedByName": addedByName,
      if (!isUpdate) "date": FieldValue.serverTimestamp(),
      if (isUpdate) "updatedAt": FieldValue.serverTimestamp(),
    };
  }
}
