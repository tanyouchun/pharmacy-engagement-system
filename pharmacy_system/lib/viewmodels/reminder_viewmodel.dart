import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/reminder.dart';
import '../models/prescription.dart';
import '../constants/error_message.dart';
import '../services/notification_service.dart';

/// ViewModel responsible for managing medication reminders.
/// It handles:
/// - Retrieving user reminders
/// - Creating new reminders
/// - Updating existing reminders
/// - Deleting reminders
/// - Scheduling medication notifications
/// - Managing medication reminder schedules
class ReminderViewModel extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<Reminder> _reminders = [];
  List<Reminder> get reminders => _reminders;

  String get userId => _auth.currentUser!.uid;

  /// Retrieves all medication reminders created by the current user.
  Future<void> fetchReminders() async {
    final snapshot =
        await _db
            .collection('reminders')
            .where('userId', isEqualTo: userId)
            .get();

    _reminders =
        snapshot.docs
            .map((doc) => Reminder.fromMap(doc.id, doc.data()))
            .toList();

    notifyListeners();
  }

  /// Creates a new medication reminder or updates an existing reminder.
  ///
  /// Validation is performed to ensure:
  /// - A prescription has been selected.
  /// - Duplicate reminders are prevented for the same prescription.
  Future<String?> saveReminder({
    required bool isEditing,
    Reminder? existingReminder,
    required Prescription? selectedPrescription,
    required TimeOfDay selectedTime,
    required String frequency,
    required String medicationName,
    required String strength,
    required String dose,
    required String durationText,
    required String durationOption,
  }) async {
    if (selectedPrescription == null) {
      return "Please select a prescription";
    }

    if (!isEditing &&
        await reminderExists(selectedPrescription.prescriptionId)) {
      return "Reminder already exists for this prescription";
    }

    final now = DateTime.now();

    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final duration =
        durationOption == "other"
            ? int.tryParse(durationText.trim()) ?? 7
            : int.parse(durationOption);

    final reminderTimes = generateReminderTimes(selectedTime, frequency);

    if (!isEditing) {
      await createReminder(
        Reminder(
          reminderId: "",
          userId: userId,
          prescriptionId: selectedPrescription.prescriptionId,
          medicationName:
              selectedPrescription.medicationName.isNotEmpty
                  ? selectedPrescription.medicationName
                  : medicationName,
          strength: strength,
          dose: dose,
          scheduleTime: dateTime,
          frequency: frequency,
          reminderTimes: reminderTimes,
          isActive: true,
          duration: duration,
        ),
      );
    } else {
      log("Editing existing reminder with id: ${existingReminder!.reminderId}");
      await updateReminder(
        existingReminder.copyWith(
          prescriptionId: selectedPrescription.prescriptionId,
          medicationName:
              selectedPrescription.medicationName.isNotEmpty
                  ? selectedPrescription.medicationName
                  : medicationName,
          strength: strength,
          dose: dose,
          scheduleTime: dateTime,
          frequency: frequency,
          reminderTimes: reminderTimes,
          isActive: true,
          duration: duration,
        ),
      );
    }

    return null;
  }

  /// Adds a new reminder into Firestore database.
  ///
  /// After storing the reminder, notification schedules are created
  /// using NotificationService to remind users when medication should be taken.
  Future<void> createReminder(Reminder reminder) async {
    try {
      final docRef = _db.collection('reminders').doc();
      final reminderData = reminder.toMap()..['reminderId'] = docRef.id;

      await docRef.set(reminderData);

      await NotificationService.instance.scheduleReminderTimes(
        reminderId: docRef.id,
        prescriptionId: reminder.prescriptionId,
        userId: reminder.userId,
        medicationName: reminder.medicationName,
        reminderTimes: reminder.reminderTimes,
      );

      log("Reminder created: $reminderData");
      await fetchReminders();
    } catch (e) {
      log("${ErrorMessage.STORE_REMINDER_ERROR}: $e");
      return;
    }
  }

  /// Updates an existing medication reminder.
  ///
  /// Before updating:
  /// - Existing notifications are cancelled.
  /// - Previous medication logs are removed.
  ///
  /// New notification schedules are created after updating the reminder.
  Future<void> updateReminder(Reminder reminder) async {
    try {
      log(
        "Updating reminder:"
        " oldPrescription=${reminder.prescriptionId}",
      );
      await NotificationService.instance.cancelReminder(
        reminder.reminderId,
        reminder.reminderTimes.length,
      );

      final logs =
          await FirebaseFirestore.instance
              .collection('medication_logs')
              .where('reminderId', isEqualTo: reminder.reminderId)
              .get();

      final batch = FirebaseFirestore.instance.batch();

      for (final doc in logs.docs) {
        batch.delete(doc.reference);
      }
      log(
        "Deleted ${logs.docs.length} medication logs for reminder id: ${reminder.reminderId}",
      );

      await batch.commit();

      await _db
          .collection('reminders')
          .doc(reminder.reminderId)
          .update(reminder.toMap());

      await NotificationService.instance.scheduleReminderTimes(
        reminderId: reminder.reminderId,
        prescriptionId: reminder.prescriptionId,
        userId: reminder.userId,
        medicationName: reminder.medicationName,
        reminderTimes: reminder.reminderTimes,
      );
      log("Reminder updated: ${reminder.toMap()}");

      await fetchReminders();
    } catch (e) {
      log("${ErrorMessage.UPDATE_REMINDER_ERROR}: $e");
      return;
    }
  }

  /// Deletes a medication reminder.
  Future<void> deleteReminder(Reminder reminder) async {
    try {
      await NotificationService.instance.cancelReminder(
        reminder.reminderId,
        reminder.reminderTimes.length,
      );

      final logs =
          await FirebaseFirestore.instance
              .collection('medication_logs')
              .where('reminderId', isEqualTo: reminder.reminderId)
              .get();

      final batch = FirebaseFirestore.instance.batch();

      for (final doc in logs.docs) {
        batch.delete(doc.reference);
      }

      log(
        "Deleted ${logs.docs.length} medication logs for reminder id: ${reminder.reminderId}",
      );

      await batch.commit();

      await _db.collection('reminders').doc(reminder.reminderId).delete();
      log("Reminder deleted for reminder id: ${reminder.reminderId}");

      await fetchReminders();
    } catch (e) {
      log("${ErrorMessage.DELETE_REMINDER_ERROR}: $e");
      return;
    }
  }

  /// Generates medication reminder times based on frequency.
  List<String> generateReminderTimes(TimeOfDay startTime, String frequency) {
    int timesPerDay = 1;

    switch (frequency.toLowerCase()) {
      case "twice daily":
        timesPerDay = 2;
        break;

      case "three times daily":
        timesPerDay = 3;
        break;

      case "four times daily":
        timesPerDay = 4;
        break;

      default:
        timesPerDay = 1;
    }

    final intervalHours = 24 ~/ timesPerDay;

    final times = <String>[];

    for (int i = 0; i < timesPerDay; i++) {
      final hour = (startTime.hour + (intervalHours * i)) % 24;

      final formatted =
          "${hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";

      times.add(formatted);
    }

    return times;
  }

  /// Checks whether a reminder already exists for a prescription.
  Future<bool> reminderExists(String prescriptionId) async {
    final snapshot =
        await _db
            .collection('reminders')
            .where('userId', isEqualTo: userId)
            .where('prescriptionId', isEqualTo: prescriptionId)
            .get();
    log(
      "Checking prescriptionId=$prescriptionId "
      "found=${snapshot.docs.length}",
    );

    for (final doc in snapshot.docs) {
      log(doc.data().toString());
    }

    return snapshot.docs.isNotEmpty;
  }

  /// Determines whether the medication reminder time has passed.
  bool canTake(String time) {
    final now = DateTime.now();

    final parts = time.split(':');

    final reminderTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    return now.isAfter(reminderTime);
  }
}
