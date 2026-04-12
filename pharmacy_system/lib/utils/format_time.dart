import 'package:cloud_firestore/cloud_firestore.dart';

class FormatTime {
  static String formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "";

    final date = timestamp.toDate();
    final now = DateTime.now();

    if (now.difference(date).inDays == 0) {
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } else {
      return "${date.day}/${date.month}";
    }
  }
}