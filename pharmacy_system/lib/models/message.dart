import 'package:cloud_firestore/cloud_firestore.dart';

/// Message model represents an individual message
/// exchanged between users in a chat conversation.
///
/// This model stores:
/// - Message identifier.
/// - Sender information.
/// - Message content.
/// - Message editing status.
/// - Read status.
/// - Sent timestamp.
class Message {
  final String messageId;
  final String senderId;
  final String messageText;
  final bool isEdited;
  final bool isRead;
  final DateTime timestamp;

  Message({
    required this.messageId,
    required this.senderId,
    required this.messageText,
    required this.isEdited,
    this.isRead = false,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'messageText': messageText,
      'edited': isEdited,
      'isRead': isRead,
      'timestamp': timestamp,
    };
  }

  factory Message.fromMap(String id, Map<String, dynamic> map) {
    return Message(
      messageId: id,
      senderId: map['senderId'] ?? '',
      messageText: map['messageText'] ?? '',
      isEdited: map['isEdited'] ?? false,
      isRead: map['isRead'] ?? false,
      timestamp:
          map['timestamp'] != null
              ? (map['timestamp'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }
}
