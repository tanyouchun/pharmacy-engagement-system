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
      await _db
          .collection('reminders')
          .doc(reminder.reminderId)
          .update(reminder.toMap());

      await NotificationService.instance.scheduleReminderTimes(
        reminderId: reminder.reminderId,
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

      await _db.collection('reminders').doc(reminder.reminderId).delete();
      log("Reminder deleted for reminder id: ${reminder.reminderId}");

      await fetchReminders();
    } catch (e) {
      log("${ErrorMessage.DELETE_REMINDER_ERROR}: $e");
      return;
    }
  }
}
