import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String reminderId;
  final String userId;
  final String prescriptionId;
  final String medicationName;
  final DateTime scheduleTime;
  final String frequency; // e.g. "Once daily"
  final List<String> reminderTimes; // e.g. ["08:00", "20:00"]
  final bool isActive;

  Reminder({
    required this.reminderId,
    required this.userId,
    required this.prescriptionId,
    required this.medicationName,
    required this.scheduleTime,
    required this.frequency,
    required this.reminderTimes,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'reminderId': reminderId,
      'userId': userId,
      'prescriptionId': prescriptionId,
      'medicationName': medicationName,
      'scheduleTime': Timestamp.fromDate(scheduleTime),
      'frequency': frequency,
      'reminderTimes': reminderTimes,
      'isActive': isActive,
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
      reminderTimes:
          map['reminderTimes'] != null
              ? List<String>.from(map['reminderTimes'])
              : [],
      isActive: map['isActive'] ?? false,
    );
  }

  Reminder copyWith({
    String? medicationName,
    DateTime? time,
    String? frequency,
    List<String>? reminderTimes,
    bool? isActive,
  }) {
    return Reminder(
      reminderId: reminderId,
      userId: userId,
      prescriptionId: prescriptionId,
      medicationName: medicationName ?? this.medicationName,
      scheduleTime: time ?? scheduleTime,
      frequency: frequency ?? this.frequency,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      isActive: isActive ?? this.isActive,
    );
  }
}
