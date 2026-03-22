import 'package:cloud_firestore/cloud_firestore.dart';

class Prescription {
  final String id;
  final String name;
  final String notes;
  final String date;

  Prescription({
    required this.id,
    required this.name,
    required this.notes,
    required this.date,
  });

  factory Prescription.fromMap(String id, Map<String, dynamic> data) {
    final rawDate = data['date'] ?? '';

    String formattedDate = "";

    if (rawDate is Timestamp) {
      final date = rawDate.toDate();
      formattedDate = "${date.day}/${date.month}/${date.year}";
    } else {
      formattedDate = rawDate?.toString() ?? "";
    }

    return Prescription(
      id: id,
      name: data['name'] ?? '',
      notes: data['notes'] ?? '',
      date: formattedDate,
    );
  }
}
