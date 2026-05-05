import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/reminder.dart';
import '../constants/error_message.dart';

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
      await _db.collection('reminders').add(reminder.toMap());
      log("Reminder created: ${reminder.toMap()}");
      await fetchReminders();
    } catch (e) {
      log("${ErrorMessage.STORE_REMINDER_ERROR}: $e");
      return;
    }
  }

  //update reminders/{id}
  Future<void> updateReminder(Reminder reminder) async {
    try {
      await _db
          .collection('reminders')
          .doc(reminder.reminderId)
          .update(reminder.toMap());
      log("Reminder updated: ${reminder.toMap()}");

      await fetchReminders();
    } catch (e) {
      log("${ErrorMessage.UPDATE_REMINDER_ERROR}: $e");
      return;
    }
  }

  // delete reminders/{id}
  Future<void> deleteReminder(String id) async {
    try {
      await _db.collection('reminders').doc(id).delete();
      log("Reminder deleted for reminder id: $id");

      await fetchReminders();
    } catch (e) {
      log("${ErrorMessage.DELETE_REMINDER_ERROR}: $e");
      return;
    }
  }
}
