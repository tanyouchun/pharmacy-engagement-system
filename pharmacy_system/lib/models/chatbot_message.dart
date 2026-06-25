import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatRole {
  user,
  assistant,
  system,
}

extension ChatRoleExtension on ChatRole {
  String get value {
    return name;
  }

  bool get isUser => this == ChatRole.user;
  bool get isAssistant => this == ChatRole.assistant;
  bool get isSystem => this == ChatRole.system;
}

class ChatMessage {
  final ChatRole role;
  final String content;
  final DateTime? timestamp;

  const ChatMessage({
    required this.role,
    required this.content,
    this.timestamp,
  });

  ChatMessage copyWith({
    ChatRole? role,
    String? content,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role.value,
      'content': content,
      if (timestamp != null) 'timestamp': timestamp,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    final roleValue = map['role'] as String?;
    final timestampValue = map['timestamp'];

    return ChatMessage(
      role: ChatRole.values.firstWhere(
        (r) => r.value == roleValue,
        orElse: () => ChatRole.user,
      ),
      content: map['content'] as String? ?? '',
      timestamp: timestampValue is Timestamp
          ? timestampValue.toDate()
          : timestampValue is DateTime
              ? timestampValue
              : null,
    );
  }

  factory ChatMessage.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return ChatMessage.fromMap(data ?? {});
  }
}
