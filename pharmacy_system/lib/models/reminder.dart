import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String reminderId;
  final String userId;
  final String prescriptionId;
  final String medicationName;
  final DateTime scheduleTime;
  final String frequency; // e.g. "Once daily"

  Reminder({
    required this.reminderId,
    required this.userId,
    required this.prescriptionId,
    required this.medicationName,
    required this.scheduleTime,
    required this.frequency,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'prescriptionId': prescriptionId,
      'medicationName': medicationName,
      'scheduleTime': scheduleTime,
      'frequency': frequency,
    };
  }

  factory Reminder.fromMap(String id, Map<String, dynamic> map) {
    return Reminder(
      reminderId: id,
      userId: map['userId'] ?? '',
      prescriptionId: map['prescriptionId'] ?? '',
      medicationName: map['medicationName'] ?? '',
      scheduleTime:
          map['scheduleTime'] is Timestamp
              ? (map['scheduleTime'] as Timestamp).toDate()
              : map['scheduleTime'] is String
              ? DateTime.parse(map['scheduleTime'])
              : DateTime.now(),
      frequency: map['frequency'],
    );
  }

  Reminder copyWith({
    String? medicationName,
    DateTime? time,
    String? frequency,
  }) {
    return Reminder(
      reminderId: reminderId,
      userId: userId,
      prescriptionId: prescriptionId,
      medicationName: medicationName ?? this.medicationName,
      scheduleTime: time ?? this.scheduleTime,
      frequency: frequency ?? this.frequency,
    );
  }
}
