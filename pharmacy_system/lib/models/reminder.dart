class Reminder {
  final String id;
  final String userId;
  final String prescriptionId;
  final String medicationName;
  final DateTime time;
  final String frequency; // e.g. "Once daily"

  Reminder({
    required this.id,
    required this.userId,
    required this.prescriptionId,
    required this.medicationName,
    required this.time,
    required this.frequency,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'prescriptionId': prescriptionId,
      'medicationName': medicationName,
      'time': time.toIso8601String(),
      'frequency': frequency,
    };
  }

  factory Reminder.fromMap(String id, Map<String, dynamic> map) {
    return Reminder(
      id: id,
      userId: map['userId'],
      prescriptionId: map['prescriptionId'],
      medicationName: map['medicationName'],
      time: DateTime.parse(map['time']),
      frequency: map['frequency'],
    );
  }

  Reminder copyWith({
    String? medicationName,
    DateTime? time,
    String? frequency,
  }) {
    return Reminder(
      id: id,
      userId: userId,
      prescriptionId: prescriptionId,
      medicationName: medicationName ?? this.medicationName,
      time: time ?? this.time,
      frequency: frequency ?? this.frequency,
    );
  }
}
