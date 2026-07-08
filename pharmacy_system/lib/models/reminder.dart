import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String reminderId;
  final String userId;
  final String prescriptionId;
  final String medicationName;
  final String strength;
  final String dose;
  final int duration;
  final DateTime scheduleTime;
  final String frequency; // e.g. "Once daily"
  final List<String> reminderTimes; // e.g. ["08:00", "20:00"]
  final bool isActive;
  final int consecutiveMissedDoses;
  final bool adherenceAlertSent;
  final String lastDoseStatus;

  Reminder({
    required this.reminderId,
    required this.userId,
    required this.prescriptionId,
    required this.medicationName,
    required this.strength,
    required this.dose,
    required this.duration,
    required this.scheduleTime,
    required this.frequency,
    required this.reminderTimes,
    required this.isActive,
    this.consecutiveMissedDoses = 0,
    this.adherenceAlertSent = false,
    this.lastDoseStatus = 'none',
  });

  Map<String, dynamic> toMap() {
    return {
      'reminderId': reminderId,
      'userId': userId,
      'prescriptionId': prescriptionId,
      'medicationName': medicationName,
      'strength': strength,
      'dose': dose,
      'duration': duration,
      'scheduleTime': Timestamp.fromDate(scheduleTime),
      'frequency': frequency,
      'reminderTimes': reminderTimes,
      'isActive': isActive,
      'consecutiveMissedDoses': consecutiveMissedDoses,
      'adherenceAlertSent': adherenceAlertSent,
      'lastDoseStatus': lastDoseStatus,
    };
  }

  factory Reminder.fromMap(String id, Map<String, dynamic> map) {
    return Reminder(
      reminderId: id,
      userId: map['userId'] ?? '',
      prescriptionId: map['prescriptionId'] ?? '',
      medicationName: map['medicationName'] ?? '',
      strength: map['strength'] ?? '',
      dose: map['dose'] ?? '',
      scheduleTime:
          map['scheduleTime'] is Timestamp
              ? (map['scheduleTime'] as Timestamp).toDate()
              : map['scheduleTime'] is String
              ? DateTime.parse(map['scheduleTime'])
              : DateTime.now(),
      frequency: map['frequency'] ?? '',
      duration: map['duration'] ?? 0,
      reminderTimes:
          map['reminderTimes'] != null
              ? List<String>.from(map['reminderTimes'])
              : [],
      isActive: map['isActive'] ?? false,
      consecutiveMissedDoses: map['consecutiveMissedDoses'] ?? 0,
      adherenceAlertSent: map['adherenceAlertSent'] ?? false,
      lastDoseStatus: map['lastDoseStatus'] ?? 'none',
    );
  }

  Reminder copyWith({
    String? prescriptionId,
    String? medicationName,
    String? strength,
    String? dose,
    DateTime? scheduleTime,
    String? frequency,
    List<String>? reminderTimes,
    bool? isActive,
    int? duration,
    int? consecutiveMissedDoses,
    bool? adherenceAlertSent,
    String? lastDoseStatus,
  }) {
    return Reminder(
      reminderId: reminderId,
      userId: userId,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      medicationName: medicationName ?? this.medicationName,
      strength: strength ?? this.strength,
      dose: dose ?? this.dose,
      scheduleTime: scheduleTime ?? this.scheduleTime,
      frequency: frequency ?? this.frequency,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      isActive: isActive ?? this.isActive,
      duration: duration ?? this.duration,
      consecutiveMissedDoses:
          consecutiveMissedDoses ?? this.consecutiveMissedDoses,
      adherenceAlertSent: adherenceAlertSent ?? this.adherenceAlertSent,
      lastDoseStatus: lastDoseStatus ?? this.lastDoseStatus,
    );
  }
}
