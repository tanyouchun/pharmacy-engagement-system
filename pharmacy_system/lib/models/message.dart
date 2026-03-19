import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String text;
  final bool isEdited;
  final bool isRead;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.isEdited,
    this.isRead = false,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'edited': isEdited,
      'isRead': isRead, 
      'timestamp': timestamp,
    };
  }

  factory Message.fromMap(String id, Map<String, dynamic> map) {
    return Message(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      isEdited: map['isEdited'] ?? false,
      isRead: map['isRead'] ?? false,
      timestamp:
          (map['timestamp'] as Timestamp).toDate(),
    );
  }
}