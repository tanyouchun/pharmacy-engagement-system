import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
