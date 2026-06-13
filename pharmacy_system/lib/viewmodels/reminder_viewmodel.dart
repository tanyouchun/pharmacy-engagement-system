import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/reminder.dart';
import '../constants/error_message.dart';
import '../services/notification_service.dart';

class ReminderViewModel extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<Reminder> _reminders = [];
  List<Reminder> get reminders => _reminders;

  String get userId => _auth.currentUser!.uid;

  // get reminders/?userId={userId}
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

  // add reminders/
  Future<void> createReminder(Reminder reminder) async {
    try {
      final docRef = _db.collection('reminders').doc();
      final reminderData = reminder.toMap()..['reminderId'] = docRef.id;

      await docRef.set(reminderData);

      await NotificationService.instance.scheduleReminderTimes(
        reminderId: docRef.id,
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

  //update reminders/{id}
  Future<void> updateReminder(Reminder reminder) async {
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
      log("Deleted ${logs.docs.length} medication logs for reminder id: ${reminder.reminderId}");

      await batch.commit();

      await _db
          .collection('reminders')
          .doc(reminder.reminderId)
          .update(reminder.toMap());

      await NotificationService.instance.scheduleReminderTimes(
        reminderId: reminder.reminderId,
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

  // delete reminders/{id}
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

      log("Deleted ${logs.docs.length} medication logs for reminder id: ${reminder.reminderId}");

      await batch.commit();

      await _db.collection('reminders').doc(reminder.reminderId).delete();
      log("Reminder deleted for reminder id: ${reminder.reminderId}");

      await fetchReminders();
    } catch (e) {
      log("${ErrorMessage.DELETE_REMINDER_ERROR}: $e");
      return;
    }
  }

  Future<bool> reminderExists(String prescriptionId) async {
    final snapshot =
        await _db
            .collection('reminders')
            .where('userId', isEqualTo: userId)
            .where('prescriptionId', isEqualTo: prescriptionId)
            .get();

    return snapshot.docs.isNotEmpty;
  }

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
