import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat.dart';

/// Service responsible for creating and retrieving chat sessions
/// between patients and pharmacists.
///
/// This service ensures that only one chat conversation exists
/// for each patient-pharmacist pair.
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a new chat or returns an existing chat ID.
  Future<String> createOrGetChat(String pharmacistId) async {
    final user = FirebaseAuth.instance.currentUser!;
    final chats = _firestore.collection('chats');

    final query =
        await chats.where('participants', arrayContains: user.uid).get();

    for (var doc in query.docs) {
      List participants = doc['participants'];
      if (participants.contains(pharmacistId)) {
        return doc.id; // existing chat
      }
    }
    // Create a new chat if no existing conversation is found.
    final chat = Chat(
      chatId: '',
      participants: [user.uid, pharmacistId],
      lastMessage: '',
      lastTimestamp: DateTime.now(),
    );

    final newChat = await chats.add(chat.toMap());

    return newChat.id;
  }
}
