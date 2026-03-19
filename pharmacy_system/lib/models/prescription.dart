class Prescription {
  String id;
  String name;
  String notes;
  String date;

  Prescription({
    required this.id,
    required this.name,
    required this.notes,
    required this.date,
  });

  factory Prescription.fromMap(String id, Map<String, dynamic> data) {
    return Prescription(
      id: id,
      name: data['name'] ?? '',
      notes: data['notes'] ?? '',
      date: data['date'] ?? '',
    );
  }
}
