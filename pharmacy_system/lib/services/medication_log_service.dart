import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationLogService {
  final _db = FirebaseFirestore.instance;

  Future<void> createAndMarkTaken({
    required String reminderId,
    required String userId,
    required String reminderTime,
  }) async {
    final now = DateTime.now();
    final today = "${now.year}-${now.month}-${now.day}";

    final docId = "${reminderId}_${reminderTime}_$today";

    await _db.collection('medication_logs').doc(docId).set({
      'reminderId': reminderId,
      'userId': userId,
      'reminderTime': reminderTime,
      'taken': true,
      'takenAt': Timestamp.now(),
    });
  }

  Future<bool> alreadyTaken({
    required String reminderId,
    required String reminderTime,
  }) async {
    final now = DateTime.now();

    final today = "${now.year}-${now.month}-${now.day}";

    final docId = "${reminderId}_${reminderTime}_$today";

    final doc = await _db.collection('medication_logs').doc(docId).get();

    return doc.exists;
  }
}
