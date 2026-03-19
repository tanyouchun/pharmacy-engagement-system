import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reminder.dart';

class ReminderViewModel extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<Reminder> _reminders = [];
  List<Reminder> get reminders => _reminders;

  String get userId => _auth.currentUser!.uid;

  /// LOAD reminders
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

    notifyListeners(); // 🔥 important
  }

  /// CREATE
  Future<void> createReminder(Reminder reminder) async {
    try {
      await _db.collection('reminders').add(reminder.toMap());
      await fetchReminders(); // refresh UI
    } catch (e) {
      throw Exception("Failed to create reminder");
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _db.collection('reminders').doc(reminder.id).update(reminder.toMap());

    await fetchReminders(); // refresh UI
  }

  /// DELETE
  Future<void> deleteReminder(String id) async {
    await _db.collection('reminders').doc(id).delete();
    await fetchReminders();
  }
}
